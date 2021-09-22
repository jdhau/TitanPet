// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract TitanRock is ERC721, ReentrancyGuard, Ownable, VRFConsumerBase {
    
    ERC20Burnable s_titanToken = ERC20Burnable(0x1cd2ffDb2CbDd10e1124841038A8ed6603f91016);
    uint256 s_mintPrice = 1000000000000000000;
    uint256 s_amountMinted = 0;
    
    // Chainlink settings (MUMBAI TESTNET)
    address constant c_vrfLinkToken = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    address constant c_vrfCoordinator = 0x8C7382F9D8f56b33781fE506E897a4F1e2d17255;
    bytes32 constant c_vrfKeyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
    uint256 constant c_vrfFee = 0.0001 * 10 ** 18;
    
    mapping(uint256=>uint256) private s_randomHashes;
    uint256 public s_masterHash = 0;
    
    constructor() 
        ERC721("Titania","TITANIA") 
        VRFConsumerBase(
            c_vrfCoordinator,
            c_vrfLinkToken
            ){
    }
    
    function mint(uint256 p_tokenId) external nonReentrant {
        require (p_tokenId>0 && p_tokenId <=101,"Invalid token ID");
        require (s_masterHash == 0, "No more minting allowed");
        uint256 titanAllowance = s_titanToken.allowance(msg.sender, address(this));
        require (titanAllowance > s_mintPrice, "Approve TITAN first");
        s_titanToken.transferFrom(msg.sender,address(this),s_mintPrice);
        _safeMint(msg.sender, p_tokenId);
        s_randomHashes[p_tokenId] = uint256(blockhash(block.number - 2))
            ^ block.timestamp
            ^ block.difficulty
            ^ p_tokenId
            ^ uint256(keccak256(abi.encodePacked(block.coinbase)));
        s_amountMinted += 1;
        if (s_amountMinted==100) {
            requestRandomness(c_vrfKeyHash, c_vrfFee);
        }
    }

    function mutltiMint(uint256 p_tokenId) external nonReentrant {
        uint256 titanAllowance = s_titanToken.allowance(msg.sender, address(this));
        require (titanAllowance > s_mintPrice, "Approve TITAN first");
        s_titanToken.transferFrom(msg.sender,address(this),s_mintPrice);
        _safeMint(msg.sender, p_tokenId);
        s_randomHashes[p_tokenId] = uint256(blockhash(block.number - 2))
            ^ block.timestamp
            ^ block.difficulty
            ^ p_tokenId
            ^ uint256(keccak256(abi.encodePacked(block.coinbase)));
    }

    function testRandom() external onlyOwner {
        requestRandomness(c_vrfKeyHash, c_vrfFee);
    }
    
    function setMintPrice(uint256 p_mintPrice) public {
        s_mintPrice = p_mintPrice;
    }
    
    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 p_requestId, uint256 p_randomness) internal override {
        s_masterHash = p_randomness;
    }
}

