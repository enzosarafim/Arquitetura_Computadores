package meuredesimples;

module Node
{
    parameters:
        @display("i=block/node");
        bool isRouter = default(false);
    gates:
        inout port[];
}

module Host extends Node
{
    parameters:
        @display("i=device/pc");
}

network NetworkTopology
{
    submodules:
        router: Node {
            isRouter = true;
            @display("p=200,100;i=device/router");
        }
        hostA: Host {
            @display("p=100,200");
        }
        hostB: Host {
            @display("p=300,200");
        }
    connections:
        hostA.port++ <--> { datarate = 100Mbps; delay = 1ms; } <--> router.port++;
        hostB.port++ <--> { datarate = 100Mbps; delay = 1ms; } <--> router.port++;
}
