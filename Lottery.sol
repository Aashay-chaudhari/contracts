//SPDX-License-Identifier : MIT

pragma solidity 0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

error getTicket_NotEnoughMoneyForTicketFee();
error getTicket_MoreMoneyThanRequired();

contract Lottery is VRFConsumerBaseV2 {
    //contract variables
    enum contractState {
        OPEN, CALCULATING
    }
    contractState public contract_state;

    //Below values are for rinkeby. 
    VRFCoordinatorV2Interface v2Interface;
    uint64 s_subscriptionId;
    address public i_owner;
    address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;
    bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint256[] public s_randomWords;
    uint256 public s_requestId;

    //Contract state variables
    address[] public s_players;
    uint256 constant public TICKET_FEE = 50;
    uint256 public s_indexOfWinner;
    address public s_addressOfWinner;

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator){
        v2Interface = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
        i_owner = msg.sender;
        //i need a button to give user,once he clicks it, vrf is called, randomness array is populated.
        //call another function to get string value.
    }

    function getTicket() public payable {
        if(msg.value> TICKET_FEE) revert getTicket_MoreMoneyThanRequired();
        if(msg.value< TICKET_FEE) revert getTicket_NotEnoughMoneyForTicketFee();
        s_players.push(msg.sender);
    }

    function pickWinner() public payable {
        s_indexOfWinner = (s_randomWords[0] % s_players.length);
        s_addressOfWinner = s_players[s_indexOfWinner];
        payable(s_addressOfWinner).transfer(address(this).balance);
    }

      // Assumes the subscription is funded sufficiently.
    function getRandomWords(uint32 numberOfWordsToReturn) public onlyOwner {
        // Will revert if subscription is not set and funded.
        contract_state = contractState.CALCULATING;
        s_requestId = v2Interface.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numberOfWordsToReturn
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
