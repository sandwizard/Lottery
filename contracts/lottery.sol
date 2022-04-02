//SPDX-License-Identifier: MIT
 pragma solidity ^0.8.13;

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";


 contract Lottery is VRFConsumerBaseV2{
     address payable[] public players;
     uint public lotteryId ;
     mapping (uint => address) public lotterywinners;
     LinkTokenInterface LINKTOKEN;
     VRFCoordinatorV2Interface COORDINATOR;
    
    uint64 s_subscriptionId;
    event winnerPicked(uint256 randomNumber);
    // Rinkeby coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;

    // Rinkeby LINK token contract. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address link = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords =  1;

    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address public s_owner;

    modifier onlyOwner() {
    require(msg.sender == s_owner);
    _;
    }

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) { // rinkeby vrf cordinator address
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
        lotteryId = 1;
                
    }
    function requestRandomWords() internal onlyOwner {
    // Will revert if subscription is not set and funded.
      s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
    }
    function fulfillRandomWords(uint256, /* requestId */uint256[] memory randomWord) internal override {
        s_randomWords = randomWord;
        emit winnerPicked(s_randomWords[0]);
        }



    function enterLottery() external payable{
         require(msg.value > 1 gwei);
         players.push(payable(msg.sender));
     }


     function getPlayers() external view returns(address payable[] memory) {
         return players;

     }
     function pickWinner() external onlyOwner {
        require(players.length != 0,"no players in lottery" );
        require(address(this).balance != 0 ether,"no monery in pot");
        requestRandomWords();       
         
     }

     function payWinner() external onlyOwner{
         require(s_randomWords.length !=0,"random number pending wiat few min");
        
         uint index = s_randomWords[0] % players.length;
         players[index].transfer(address(this).balance);
        

         lotterywinners[lotteryId] = players[index];
         lotteryId ++;
         

         
         // reset state of players;
         players = new address payable[](0);
         s_randomWords = new uint256[](0);

     }

     function potbalaance()external view returns (uint){
         return (address(this).balance);
     }

 }