#include "xparameters.h"
#include "xstatus.h"
#include "xuartlite.h"

#define UARTLITE_DEVICE_ID  ( XPAR_AXI_UARTLITE_0_DEVICE_ID )

int SendAndReceive(u16 DeviceId);

XUartLite UartLite;
u8 RecvBuffer[100];

int main(void)
{
    int Status;

    Status = SendAndReceive(UARTLITE_DEVICE_ID);
    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    return XST_SUCCESS;

}

int SendAndReceive(u16 DeviceId)
{
    int Status;
    unsigned int ReceivedCount = 0;

    Status = XUartLite_Initialize(&UartLite, DeviceId);
    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    Status = XUartLite_SelfTest(&UartLite);
    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    // send
    u8 testmsg[] = "Custom PMOD Uart Interface \r\n";
    XUartLite_Send(&UartLite, testmsg, sizeof(testmsg));
    usleep(200000); // 200msec

    // receive
    while (1) {
        ReceivedCount += XUartLite_Recv(&UartLite,
                       RecvBuffer + ReceivedCount,
                       1);
        if (RecvBuffer[ReceivedCount - 1] == '\r') {
            break;
        }
    }

    print("You have received:");
    print(RecvBuffer);
    print("\r\n");

    return XST_SUCCESS;
}
