//SPDX-License-Identifier : MIT

pragma solidity 0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract magic8 is VRFConsumerBaseV2 {
    
    enum contractState {
        OPEN, CALCULATING
    }

    contractState public contract_state;

    VRFCoordinatorV2Interface v2Interface;

    string[] public magic8_data = ["Please play rollBall to start.","Value1","Value2","Value3","Value4","Value5","Value6","Value7","Value8"];
    uint64 s_subscriptionId;
    address public i_owner;
    uint256 public s_ballRoll;
    string public magic8Response;

    //Below values are for rinkeby. 
    address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;
    bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  2;


    uint256[] public s_randomWords;
    uint256 public s_requestId;

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator){
        v2Interface = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
        i_owner = msg.sender;
        magic8Response = "first";
        //i need a button to give user,once he clicks it, vrf is called, randomness array is populated.
        //call another function to get string value.
    }

    function prediction() public view returns (string memory response) {
        return magic8Response;
    }

    function rollBall() public {
        //add a minimum value amount to charge by using keyword payable(later)
        s_ballRoll = (s_randomWords[0] % 8 ) + 1;
        magic8Response = magic8_data[s_ballRoll];
    }

      // Assumes the subscription is funded sufficiently.
    function getRandomWords(uint32 numberOfWords) public onlyOwner {
        // Will revert if subscription is not set and funded.
        contract_state = contractState.CALCULATING;
        s_requestId = v2Interface.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numberOfWords
        );
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;
        contract_state = contractState.OPEN;
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner);
        _;
    }
}
