// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract SharkyNFTContract is ERC721, Ownable {
    using SafeERC20 for IERC20;
    using Strings for uint256;

    uint256 public totalSupply;
    uint256 public publicMintPrice;
    uint256 public whitelistMintPrice;
    uint256 public tokenCounter;
    address public payTokenAddress;
    address public fundsReceiver;
    address public admin;
    string public baseUri;
    bool public isContractActive;
    bool public publicMintIsActive;
    bool public whitelistMintIsActive;
    mapping(address => bool) public userIsWhitelisted;

    modifier onlyAllowed() {
        require(msg.sender == owner() || msg.sender == admin, "Action not allowed");
        _;
    }

    modifier onlyWhenNotPaused() {
        require(isContractActive, "Contract paused.");
        _;
    }

    modifier onlyWhenPublicMintIsActive() {
        require(publicMintIsActive, "Public mint not active.");
        _;
    }

    modifier onlyWhenWhitelistMintIsActive() {
        require(whitelistMintIsActive, "Whitelist mint not active.");
        _;
    }

    event TokenMinted(address userAddress_, uint256 tokenId_);

    constructor(string memory name_, string memory symbol_, string memory baseUri_, uint256 publicMintPrice_, uint256 whitelistMintPrice_, uint256 totalSupply_, address owner_, address fundsReceiver_, address admin_, address payTokenAddress_) ERC721(name_, symbol_) Ownable(owner_) {
        baseUri = baseUri_;
        publicMintPrice = publicMintPrice_;
        whitelistMintPrice = whitelistMintPrice_;
        totalSupply = totalSupply_;
        payTokenAddress = payTokenAddress_;
        fundsReceiver = fundsReceiver_;
        admin = admin_;
    }

    function mintPublic(uint256 amount_) external onlyWhenNotPaused() onlyWhenPublicMintIsActive() {
        require(tokenCounter + amount_ <= totalSupply, "Sold out");
        for (uint256 i = 0; i < amount_; i++) {
            IERC20(payTokenAddress).safeTransferFrom(msg.sender, fundsReceiver, publicMintPrice);

            uint256 tokenCounter_ = tokenCounter;
            tokenCounter++;
            _safeMint(msg.sender, tokenCounter_);

            emit TokenMinted(msg.sender, tokenCounter_);
        }
    }

    function whitelistMint(uint256 amount_) external onlyWhenNotPaused() onlyWhenWhitelistMintIsActive() {
        require(tokenCounter + amount_ <= totalSupply, "Sold out");
        require(userIsWhitelisted[msg.sender], "User is not whitelisted.");

        for (uint256 i = 0; i < amount_; i++) {

            IERC20(payTokenAddress).safeTransferFrom(msg.sender, fundsReceiver, whitelistMintPrice);

            uint256 tokenCounter_ = tokenCounter;
            tokenCounter++;
            _safeMint(msg.sender, tokenCounter_);

            emit TokenMinted(msg.sender, tokenCounter_);
        }
    }

    function tokenURI(uint256 tokenId) public view override virtual returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString(), ".json") : "";
    }

    function _baseURI() internal view override virtual returns (string memory) {
        return baseUri;
    }

    function addWhitelistUser(address[] memory userAddress_) external onlyAllowed() {
        for(uint256 i = 0; i < userAddress_.length; i++) {
            userIsWhitelisted[userAddress_[i]] = true;
        }
    }

    function removeWhitelistUser(address[] memory userAddress_) external onlyAllowed() {
        for(uint256 i = 0; i < userAddress_.length; i++) {
            userIsWhitelisted[userAddress_[i]] = false;
        }
    }

    function changeMintPublicPrice(uint256 newPublicMintPrice_) external onlyOwner() {
        publicMintPrice = newPublicMintPrice_;
    }

    function changeWhitelistMintPrice(uint256 newWhitelistMintPrice_) external onlyOwner() {
        whitelistMintPrice = newWhitelistMintPrice_;
    }

    function setNewFundsReceiver(address newFundsReceiver_) external onlyOwner() {
        fundsReceiver = newFundsReceiver_;
    }

    function pauseContract() external onlyOwner() {
        isContractActive = false;
    }

    function unPauseContract() external onlyOwner() {
        isContractActive = true;
    }

    function activePublicMint() external onlyOwner() {
        publicMintIsActive = true;
    }

    function desactivatePublicMint() external onlyOwner() {
        publicMintIsActive = false;
    }

    function activeWhitelistMint() external onlyOwner() {
        whitelistMintIsActive = true;
    }

    function desactivateWhitelistMint() external onlyOwner() {
        whitelistMintIsActive = false;
    }
}