import serial
import threading

#echo opcode
OPCODE = 0xEC
RESERVED = 0x00

def send_packet(serial_port, data):
    #1 byteo pcode, 1 byte reserverd, #2 byte length lsb and msb, #x byte data
    length = len(data) + 4
    #get lsb and msb of length
    length_lsb = length & 0xFF
    length_msb = (length >> 8) & 0xFF
    packet_to_send = bytes([OPCODE, RESERVED, length_lsb, length_msb]) + data.encode("utf-8")
    serial_port.write(packet_to_send)
    print(f"Sent: {packet_to_send.hex()}")

def recieve_packet(serial_port):
    while True:
        if serial_port.in_waiting > 0:
            data = serial_port.read(serial_port.in_waiting)
            print(f"Received: {data.hex()}")

#open a serial port connection
serial_port = serial.Serial('/dev/ttyUSB0', baudrate=9600, timeout=1)

#dameon = true to exit when main finishes
thread = threading.Thread(target=recieve_packet, args=(serial_port,),daemon = True)
thread.start()

try:
    send_packet(serial_port, "Hi")
except KeyboardInterrupt:
    print("Cancelled")
finally:
    thread.join()
    serial_port.close()
    print("Serial port closed.")
