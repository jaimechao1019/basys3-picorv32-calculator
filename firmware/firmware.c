#define LED_REG (*(volatile unsigned int*)0x1000000C)

int main()
{
    unsigned int x = 0;

    while (1)
    {
        LED_REG = x++;
    }

    return 0;
}
