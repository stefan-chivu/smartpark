# This section uses firmware from Lemariva's Micropython-camera-driver.
# for details, please refer to: https://github.com/lemariva/micropython-camera-driver
import utime
import camera
from machine import Pin
import time

trig_pin = Pin(13, Pin.OUT, 0)
echo_pin = Pin(14, Pin.IN, 0)
red_led = Pin(32, Pin.OUT, 0)
green_led = Pin(33, Pin.OUT, 0)

sound_velocity = 340
distance = 0

SSID = "DIGI_CHV"         # Enter your WiFi name
PASSWORD = "giarmata2020"     # Enter your WiFi password

UPLOAD_API_URL = "http://35.211.208.184/upload.php"
SENSOR_ID = 1

OCCUPIED_CHECK_INTERVAL = 10 # 300  # 5m
FREE_CHECK_INTERVAL = 5 # 120  # 2m


# Let ESP32 connect to wifi.
def wifi_connect():
    import network
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    if not wlan.isconnected():
        print('connecting to network...')
        wlan.connect(SSID, PASSWORD)
    start = utime.time()
    while not wlan.isconnected():
        utime.sleep(1)
        if utime.time()-start > 5:
            print("connect timeout!")
            break
    if wlan.isconnected():
        print('network config:', wlan.ifconfig())


# Initializing the Camera
def camera_init():
    # Disable camera initialization
    camera.deinit()
    # Enable camera initialization
    camera.init(0, d0=4, d1=5, d2=18, d3=19, d4=36, d5=39, d6=34, d7=35,
                format=camera.JPEG, framesize=camera.FRAME_VGA,
                xclk_freq=camera.XCLK_20MHz,
                href=23, vsync=25, reset=-1, pwdn=-1,
                sioc=27, siod=26, xclk=21, pclk=22, fb_location=camera.PSRAM)

    camera.framesize(camera.FRAME_VGA)  # Set the camera resolution
    # The options are the following:
    # FRAME_96X96 FRAME_QQVGA FRAME_QCIF FRAME_HQVGA FRAME_240X240
    # FRAME_QVGA FRAME_CIF FRAME_HVGA FRAME_VGA FRAME_SVGA
    # FRAME_XGA FRAME_HD FRAME_SXGA FRAME_UXGA
    # Note: The higher the resolution, the more memory is used.
    # Note: And too much memory may cause the program to fail.

    camera.flip(1)                       # Flip up and down window: 0-1
    camera.mirror(1)                     # Flip window left and right: 0-1
    # saturation: -2,2 (default 0). -2 grayscale
    camera.saturation(0)
    # brightness: -2,2 (default 0). 2 brightness
    camera.brightness(0)
    # contrast: -2,2 (default 0). 2 highcontrast
    camera.contrast(0)
    # quality: # 10-63 lower number means higher quality
    camera.quality(10)
    # Note: The smaller the number, the sharper the image. The larger the number, the more blurry the image

    camera.speffect(camera.EFFECT_NONE)  # special effects:
    # EFFECT_NONE (default) EFFECT_NEG EFFECT_BW EFFECT_RED EFFECT_GREEN EFFECT_BLUE EFFECT_RETRO
    camera.whitebalance(camera.WB_NONE)  # white balance
    # WB_NONE (default) WB_SUNNY WB_CLOUDY WB_OFFICE WB_HOME


def get_distance():
    trig_pin.value(1)
    time.sleep_us(10)
    trig_pin.value(0)
    while not echo_pin.value():
        pass
    pingStart = time.ticks_us()
    while echo_pin.value():
        pass
    pingStop = time.ticks_us()
    pingTime = time.ticks_diff(pingStop, pingStart)
    distance = pingTime*sound_velocity//2//10000
    return int(distance)


def make_request(data, image=None):
    boundary = '---011000010111000001101001'
    # boundary fixed instead of generating new one everytime

    def encode_field(field_name):  # prepares lines that include chat_id
        return (
            b'--%s' % boundary,
            b'Content-Disposition: form-data; name="%s"' % field_name,
            b'',
            b'%s' % data[field_name]  # field_name conatains chat_id
        )

    def encode_file(field_name):  # prepares lines for the file
        filename = 'latest.jpg'  # dummy name is assigned to uploaded file
        return (
            b'--%s' % boundary,
            b'Content-Disposition: form-data; name="%s"; filename="%s"' % (
                field_name, filename),
            b'',
            image
        )

    lines = []  # empty array initiated
    for name in data:
        lines.extend(encode_field(name))  # adding lines (data)

    if image:
        lines.extend(encode_file('imageFile'))  # adding lines  image
    lines.extend((b'--%s--' % boundary, b''))  # ending  with boundary

    body = b'\r\n'.join(lines)  # joining all lines constitues body
    body = body + b'\r\n'  # extra addtion at the end of file

    headers = {
        'content-type': 'multipart/form-data; boundary=' + boundary
    }  # removed content length parameter
    return headers, body  # body contains the assembled upload package


def upload_image(url, headers, data):
    http_response = urequests.post(
        url,
        headers=headers,
        data=data
    )
    # response status code is the output for request made
    print(http_response.status_code)

    if (http_response.status_code == 204 or http_response.status_code == 200):
        print('Uploaded request')
    else:
        print('Upload failes')
        # raise UploadError(http_response)
    http_response.close()
    return http_response


# funtion below is used to set up the file / photo to upload
def send_capture(occupied):  # path and filename combined
    buf = camera.capture()
    buf = camera.capture()
    data = {'sensorID': SENSOR_ID, 'occupied': occupied}
    headers, body = make_request(data, buf)  # generate body to upload
    del buf
    headers = {
        'content-type': "multipart/form-data; boundary=---011000010111000001101001"}
    upload_image(UPLOAD_API_URL, headers, body)  # using function to upload


if __name__ == '__main__':
    
    wifi_connect()
    
    import ulogging as logging
    import upip
    import urequests
    upip.install('micropython-urequests')
    logging.basicConfig(level=logging.INFO)
    camera_init()

    time.sleep_ms(5000)

    occupied = False
    green_led.value(1)
    red_led.value(0)
    
    interval_count = 0

    while True:
        distance = get_distance()
        print("Car is ", distance, " cm away")
        if distance <= 0:
            # Possible sensor fault
            time.sleep(OCCUPIED_CHECK_INTERVAL)
            continue
        if occupied:
            # Spot is occupied
            if (distance > 100):
                # Spot got freed
                green_led.value(1)
                red_led.value(0)
                print("Spot got freed")
                occupied = False
                send_capture(0)
                #print("Entering deepspleep")
                #deepsleep(1000 * FREE_CHECK_INTERVAL)
                #print("Back to active mode")
                time.sleep(FREE_CHECK_INTERVAL)
            else:
                interval_count += 1
                # Spot still occupied
                # Check for car change every 15m
                print("Spot still occupied")
                if (interval_count > 2):
                    print("Checking for car change")
                    send_capture(1)
                    interval_count = 0
                #print("Entering deepspleep")
                #deepsleep(1000 * OCCUPIED_CHECK_INTERVAL)
                #print("Back to active mode")
                time.sleep(OCCUPIED_CHECK_INTERVAL)
        else:
            # Spot is free
            if (distance <= 100):
                # Spot got occupied
                green_led.value(0)
                red_led.value(1)
                print("Spot got occupied")
                occupied = True
                send_capture(1)
                #print("Entering deepspleep")
                #deepsleep(1000 * OCCUPIED_CHECK_INTERVAL)
                #print("Back to active mode")
                time.sleep(OCCUPIED_CHECK_INTERVAL)
            else:
                print("Spot still free")
                #print("Entering deepspleep")
                #deepsleep(1000 * FREE_CHECK_INTERVAL)
                #print("Back to active mode")
                time.sleep(FREE_CHECK_INTERVAL)

    # debug values:
    # -1 disable all logging
    # 0 (False) normal logging: requests and errors
    # 1 (True) debug logging
    # 2 extra debug logging
