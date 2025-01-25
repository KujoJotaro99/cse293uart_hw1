#include "obj_dir/Vuart_echo_tb.h"
#include "verilated.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vuart_echo_tb* top = new Vuart_echo_tb;

    while (!Verilated::gotFinish()) {
        top->eval();
    }

    delete top;
    return 0;
}
