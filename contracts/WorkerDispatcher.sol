contract WorkAgreement {
    address client;
    address worker;
    mapping (address => bool) testers;
    uint price;
    uint end;

    function WorkAgreement(address _client, address _worker, uint _price,
                           uint length) {
        client = _client;
        worker = _worker;
        price = _price;
        end = length;
    }

    function addTester(address tester) {
        testers[tester] = true;
    }
}

contract WorkerDispatcher {
    struct Worker {
        string32 name;
        uint maxLength;
        uint price;
    }
    mapping (address => Worker) public workersInfo;
    uint numWorkers;
    mapping (uint => address) workerList;

    function buyContract(address worker, uint redundancy, uint price,
                         uint length) returns (address addr) {
        if (msg.value < length * price &&
            workersInfo[worker].name == "" &&
            workersInfo[worker].maxLength < length) return;
        WorkAgreement wa = new WorkAgreement(msg.sender, worker,
                                             price, length);
        // TODO - create better way to asign testers
        for (uint i = 1; i < 3; i++) {
            uint n = uint(block.blockhash(block.number - i)) % numWorkers;
            if (workerList[n] == worker) continue;
            wa.addTester(workerList[n]);
        }
        return wa;
    }

    function registerWorker(uint maxLength, uint price, string32 name) {
        workerList[numWorkers++] = msg.sender;
        Worker w = workersInfo[msg.sender];
        w.name = name;
        w.maxLength = maxLength;
        w.price = price;
    }

    function changeWorkerPrice(uint newPrice) {
        workersInfo[msg.sender].price = newPrice;
    }
}

