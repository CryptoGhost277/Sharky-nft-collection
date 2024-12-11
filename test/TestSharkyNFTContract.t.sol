// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "../src/SharkyNFTContract.sol";
import "../src/MockERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "forge-std/Test.sol";

contract TestSharkyNFTContract is Test {
    using Strings for uint256;

    MockERC20 payToken;
    address deployer = vm.addr(1);
    address randomUser = vm.addr(2);
    address randomUser2 = vm.addr(99);
    address randomUser3 = vm.addr(100);
    uint256 mintMockERC20Amount = 5000 ether; // 5000 USDC
    SharkyNFTContract nftContract;

    // NFT deploy parameters
    string name_ = "Sharky World NFT";
    string symbol_ = "SHRK";
    string baseUri_ = "ipfs://test/"; // DEFINIRLO
    uint256 publicMintPrice_ = 100 ether; // Confirm this
    uint256 whitelistMintPrice_ = 50 ether; // Confirm this
    uint256 totalSupply_ = 10;
    address owner_ = vm.addr(3); // Change: set correct one
    address fundsReceiver_ = vm.addr(4); // Change: set correct one
    address admin_ = vm.addr(5); // Change: set correct one

    function setUp() public {
        vm.startPrank(deployer);
        payToken = new MockERC20("Mock USDC", "MUSDC");
        nftContract = new SharkyNFTContract(name_, symbol_, baseUri_, publicMintPrice_, whitelistMintPrice_, totalSupply_, owner_, fundsReceiver_, admin_, address(payToken));
        vm.stopPrank();

        vm.startPrank(randomUser);
        payToken.mint(mintMockERC20Amount);
        vm.stopPrank();

        vm.startPrank(randomUser2);
        payToken.mint(mintMockERC20Amount);
        vm.stopPrank();
    }

    function testMintsMockCorrectly() public view {
        uint256 mockBalance = IERC20(payToken).balanceOf(randomUser);
        assert(mockBalance == mintMockERC20Amount);
    }

    function testNftDeployedCorrectly() public view {
        uint256 publicMintPrice = nftContract.publicMintPrice();
        uint256 whitelistMintPrice = nftContract.whitelistMintPrice();

        assert(whitelistMintPrice_ == whitelistMintPrice);
        assert(publicMintPrice_ == publicMintPrice);
    }

    function testCheckContractIsPaused() public view {
        bool isActive = nftContract.isContractActive();
        assert(isActive == false);
    }

    function testCheckPublicMintIsPaused() public view {
        bool isActive = nftContract.publicMintIsActive();
        assert(isActive == false);
    }

    function testCheckWhitelistMintIsPaused() public view {
        bool isActive = nftContract.whitelistMintIsActive();
        assert(isActive == false);
    }

    function testRandomUserCanNotActivateContract() public {
        vm.startPrank(randomUser);
        vm.expectRevert();
        nftContract.unPauseContract();
        vm.stopPrank();
    }

    function testRandomUserCanNotDesactivateContract() public {
        vm.startPrank(randomUser);
        vm.expectRevert();
        nftContract.pauseContract();
        vm.stopPrank();
    }

    function testOwnerCanActivateContract() public {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        bool isContractActive = nftContract.isContractActive();
        assert(isContractActive == true);
        vm.stopPrank();
    }

    function testOwnerCanDesactivateContract() public {
        vm.startPrank(owner_);
        bool isContractActive = nftContract.isContractActive();
        assert(isContractActive == false);
        nftContract.unPauseContract();
        isContractActive = nftContract.isContractActive();
        assert(isContractActive == true);
        nftContract.pauseContract();
        isContractActive = nftContract.isContractActive();
        assert(isContractActive == false);
        vm.stopPrank();
    }

    function testRandomUserCanNotActivatePublicMint() public {
        vm.startPrank(randomUser);
        vm.expectRevert();
        nftContract.activePublicMint();
        vm.stopPrank();
    }

    function testRandomUserCanNotDesactivatePublicMint() public {
        vm.startPrank(randomUser);
        vm.expectRevert();
        nftContract.desactivatePublicMint();
        vm.stopPrank();
    }

    function testOwnerCanActivatePublicMint() public {
        vm.startPrank(owner_);
        bool publicMintIsActive = nftContract.publicMintIsActive();
        assert(publicMintIsActive == false);
        nftContract.activePublicMint();
        publicMintIsActive = nftContract.publicMintIsActive();
        assert(publicMintIsActive == true);
        vm.stopPrank();
    }

    function testOwnerCanDesactivatePublicMint() public {
        vm.startPrank(owner_);
        bool publicMintIsActive = nftContract.publicMintIsActive();
        assert(publicMintIsActive == false);
        nftContract.activePublicMint();
        publicMintIsActive = nftContract.publicMintIsActive();
        assert(publicMintIsActive == true);
        nftContract.desactivatePublicMint();
        publicMintIsActive = nftContract.publicMintIsActive();
        assert(publicMintIsActive == false);
        vm.stopPrank();
    }

    function testRandomUserCanNotActivateWhitelisMint() public {
        vm.startPrank(randomUser);
        vm.expectRevert();
        nftContract.activeWhitelistMint();
        vm.stopPrank();
    }

    function testRandomUserCanNotDesactivateWhitelistMint() public {
        vm.startPrank(randomUser);
        vm.expectRevert();
        nftContract.desactivateWhitelistMint();
        vm.stopPrank();
    }

    function testOwnerCanActivateWhitelistMint() public {
        vm.startPrank(owner_);
        bool publicMintIsActive = nftContract.whitelistMintIsActive();
        assert(publicMintIsActive == false);
        nftContract.activeWhitelistMint();
        publicMintIsActive = nftContract.whitelistMintIsActive();
        assert(publicMintIsActive == true);
        vm.stopPrank();
    }

    function testOwnerCanDesactivateWhitelistMint() public {
        vm.startPrank(owner_);
        bool publicMintIsActive = nftContract.whitelistMintIsActive();
        assert(publicMintIsActive == false);
        nftContract.activeWhitelistMint();
        publicMintIsActive = nftContract.whitelistMintIsActive();
        assert(publicMintIsActive == true);
        nftContract.desactivateWhitelistMint();
        publicMintIsActive = nftContract.whitelistMintIsActive();
        assert(publicMintIsActive == false);
        vm.stopPrank();
    }

    function testRandomUserCanNotSetNewFundsReceiver() public {
        vm.startPrank(randomUser);
        vm.expectRevert();
        nftContract.setNewFundsReceiver(randomUser2);
        vm.stopPrank();
    }

    function testOwnerCanSetNewFundsReceiver() public {
        vm.startPrank(owner_);
        address fundsReceiver = nftContract.fundsReceiver();
        assert(fundsReceiver == fundsReceiver_);
        nftContract.setNewFundsReceiver(randomUser2);
        fundsReceiver = nftContract.fundsReceiver();
        assert(fundsReceiver == randomUser2);
        vm.stopPrank();
    }

    function testRandomUserCanNotSetNewPublicMintPrice() public {
        vm.startPrank(randomUser);
        vm.expectRevert();
        uint256 newPrice_ = 1 ether;
        nftContract.changeMintPublicPrice(newPrice_);
        vm.stopPrank();
    }

    function testOwnerCanSetNewPublicMintPrice() public {
        vm.startPrank(owner_);
        uint256 newPrice_ = 1 ether;
        uint256 publicMintPrice = nftContract.publicMintPrice();
        assert(publicMintPrice == publicMintPrice_);
        nftContract.changeMintPublicPrice(newPrice_);
        publicMintPrice = nftContract.publicMintPrice();
        assert(publicMintPrice == newPrice_);
        vm.stopPrank();
    }

    function testRandomUserCanNotSetNewWhitelistMintPrice() public {
        vm.startPrank(randomUser);
        vm.expectRevert();
        uint256 newPrice_ = 1 ether;
        nftContract.changeWhitelistMintPrice(newPrice_);
        vm.stopPrank();
    }

    function testOwnerCanSetNewWhitelistMintPrice() public {
        vm.startPrank(owner_);
        uint256 newPrice_ = 1 ether;
        uint256 whitelistMintPrice = nftContract.whitelistMintPrice();
        assert(whitelistMintPrice == whitelistMintPrice_);
        nftContract.changeWhitelistMintPrice(newPrice_);
        whitelistMintPrice = nftContract.whitelistMintPrice();
        assert(whitelistMintPrice == newPrice_);
        vm.stopPrank();
    }

    function testRandomUserCanNotAddWhitelist() public {
        vm.startPrank(randomUser);
        address[] memory memorers = new address[](2);
        memorers[0] = randomUser2;
        memorers[1] = randomUser3;
        vm.expectRevert("Action not allowed");
        nftContract.addWhitelistUser(memorers);
        vm.stopPrank();
    }

    function testOwnerAddWhitelist() public {
        vm.startPrank(owner_);
        address[] memory memorers = new address[](2);
        memorers[0] = randomUser2;
        memorers[1] = randomUser3;
        bool randomUser2IsWhitelisted = nftContract.userIsWhitelisted(randomUser2);
        bool randomUser3IsWhitelisted = nftContract.userIsWhitelisted(randomUser3);
        assert(!randomUser2IsWhitelisted);
        assert(!randomUser3IsWhitelisted);
        nftContract.addWhitelistUser(memorers);
        randomUser2IsWhitelisted = nftContract.userIsWhitelisted(randomUser2);
        randomUser3IsWhitelisted = nftContract.userIsWhitelisted(randomUser3);
        assert(randomUser2IsWhitelisted);
        assert(randomUser3IsWhitelisted);
        vm.stopPrank();
    }

    function testAdminAddWhitelist() public {
        vm.startPrank(admin_);
        address[] memory memorers = new address[](2);
        memorers[0] = randomUser2;
        memorers[1] = randomUser3;
        bool randomUser2IsWhitelisted = nftContract.userIsWhitelisted(randomUser2);
        bool randomUser3IsWhitelisted = nftContract.userIsWhitelisted(randomUser3);
        assert(!randomUser2IsWhitelisted);
        assert(!randomUser3IsWhitelisted);
        nftContract.addWhitelistUser(memorers);
        randomUser2IsWhitelisted = nftContract.userIsWhitelisted(randomUser2);
        randomUser3IsWhitelisted = nftContract.userIsWhitelisted(randomUser3);
        assert(randomUser2IsWhitelisted);
        assert(randomUser3IsWhitelisted);
        vm.stopPrank();
    }

    function testRandomUserCanNotRemoveWhitelist() public {
        vm.startPrank(randomUser);
        address[] memory memorers = new address[](2);
        memorers[0] = randomUser2;
        memorers[1] = randomUser3;
        vm.expectRevert("Action not allowed");
        nftContract.removeWhitelistUser(memorers);
        vm.stopPrank();
    }

    function testOwnerRemoveWhitelist() public {
        vm.startPrank(owner_);
        address[] memory memorers = new address[](2);
        memorers[0] = randomUser2;
        memorers[1] = randomUser3;
        bool randomUser2IsWhitelisted = nftContract.userIsWhitelisted(randomUser2);
        bool randomUser3IsWhitelisted = nftContract.userIsWhitelisted(randomUser3);
        assert(!randomUser2IsWhitelisted);
        assert(!randomUser3IsWhitelisted);
        nftContract.addWhitelistUser(memorers);
        randomUser2IsWhitelisted = nftContract.userIsWhitelisted(randomUser2);
        randomUser3IsWhitelisted = nftContract.userIsWhitelisted(randomUser3);
        assert(randomUser2IsWhitelisted);
        assert(randomUser3IsWhitelisted);

        nftContract.removeWhitelistUser(memorers);
        randomUser2IsWhitelisted = nftContract.userIsWhitelisted(randomUser2);
        randomUser3IsWhitelisted = nftContract.userIsWhitelisted(randomUser3);
        assert(!randomUser2IsWhitelisted);
        assert(!randomUser3IsWhitelisted);
        vm.stopPrank();
    }

    function testAdminRemoveWhitelist() public {
        vm.startPrank(admin_);
        address[] memory memorers = new address[](2);
        memorers[0] = randomUser2;
        memorers[1] = randomUser3;
        bool randomUser2IsWhitelisted = nftContract.userIsWhitelisted(randomUser2);
        bool randomUser3IsWhitelisted = nftContract.userIsWhitelisted(randomUser3);
        assert(!randomUser2IsWhitelisted);
        assert(!randomUser3IsWhitelisted);
        nftContract.addWhitelistUser(memorers);
        randomUser2IsWhitelisted = nftContract.userIsWhitelisted(randomUser2);
        randomUser3IsWhitelisted = nftContract.userIsWhitelisted(randomUser3);
        assert(randomUser2IsWhitelisted);
        assert(randomUser3IsWhitelisted);

        nftContract.removeWhitelistUser(memorers);
        randomUser2IsWhitelisted = nftContract.userIsWhitelisted(randomUser2);
        randomUser3IsWhitelisted = nftContract.userIsWhitelisted(randomUser3);
        assert(!randomUser2IsWhitelisted);
        assert(!randomUser3IsWhitelisted);
        vm.stopPrank();
    }

    function testCanNotMintPublicWhenContractPaused() public {
        vm.startPrank(randomUser);
        vm.expectRevert("Contract paused.");
        nftContract.mintPublic(1);
        vm.stopPrank();
    }

    function testCanNotMintPublicIfPublicMintIsPaused() public {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        vm.stopPrank();

        vm.startPrank(randomUser);
        vm.expectRevert("Public mint not active.");
        nftContract.mintPublic(1);
        vm.stopPrank();
    }

    function testRandomUserMints1NFTCorrectly() public {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activePublicMint();
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = 1;
        IERC20(payToken).approve(address(nftContract), publicMintPrice_);
        uint256 balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        nftContract.mintPublic(mintAmount);
        uint256 balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        assert(balanceAfter == balanceBefore + mintAmount);
        vm.stopPrank();
    }

    function testRandomUserMintsSeveralNFTCorrectly() public {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activePublicMint();
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = 3;
        IERC20(payToken).approve(address(nftContract), publicMintPrice_ * mintAmount);
        uint256 balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        nftContract.mintPublic(mintAmount);
        uint256 balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        assert(balanceAfter == balanceBefore + mintAmount);
        vm.stopPrank();
    }

    function testFundsReceiverGetsFundsFromPublicMint() public {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activePublicMint();
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = 3;
        IERC20(payToken).approve(address(nftContract), publicMintPrice_ * mintAmount);

        uint256 balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedBefore = IERC20(payToken).balanceOf(fundsReceiver_);
        nftContract.mintPublic(mintAmount);

        uint256 balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedAfter = IERC20(payToken).balanceOf(fundsReceiver_);

        uint256 fundsInContractAfter = IERC20(payToken).balanceOf(address(nftContract));

        assert(fundsInContractAfter == 0);
        assert(balanceAfter == balanceBefore + mintAmount);
        assert(fundsReceivedAfter == fundsReceivedBefore + (publicMintPrice_ * mintAmount));
        vm.stopPrank();
    }

    function testRandomUserCanMintEntireCollection() public {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activePublicMint();
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = totalSupply_;
        IERC20(payToken).approve(address(nftContract), publicMintPrice_ * mintAmount);

        uint256 balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedBefore = IERC20(payToken).balanceOf(fundsReceiver_);
        nftContract.mintPublic(mintAmount);

        uint256 balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedAfter = IERC20(payToken).balanceOf(fundsReceiver_);

        uint256 fundsInContractAfter = IERC20(payToken).balanceOf(address(nftContract));

        assert(fundsInContractAfter == 0);
        assert(balanceAfter == balanceBefore + mintAmount);
        assert(fundsReceivedAfter == fundsReceivedBefore + (publicMintPrice_ * mintAmount));
        vm.stopPrank();
    }

    function testRandomUserCanNotMintMoreThanTotalSupply() public {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activePublicMint();
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = totalSupply_ + 1;
        IERC20(payToken).approve(address(nftContract), publicMintPrice_ * mintAmount);

        vm.expectRevert("Sold out");
        nftContract.mintPublic(mintAmount);

        
        vm.stopPrank();
    }


    // Whitelist
    function testCanNotMintWhitelistWhenContractPaused() public {
        vm.startPrank(randomUser);
        vm.expectRevert("Contract paused.");
        nftContract.whitelistMint(1);
        vm.stopPrank();
    }

    function testCanNotMintWhitelistIfPublicMintIsPaused() public {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        vm.stopPrank();

        vm.startPrank(randomUser);
        vm.expectRevert("Whitelist mint not active.");
        nftContract.whitelistMint(1);
        vm.stopPrank();
    }

    function testCanNotMintWhitelistIfUserIsNotWhitelisted() public {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activeWhitelistMint();
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = 1;
        IERC20(payToken).approve(address(nftContract), whitelistMintPrice_);

        vm.expectRevert("User is not whitelisted.");
        nftContract.whitelistMint(mintAmount);
       
        vm.stopPrank();
    }

    function testRandomUserMintsWhitelist1NFTCorrectly() public {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activeWhitelistMint();
        address[] memory memorers = new address[](2);
        memorers[0] = randomUser;
        nftContract.addWhitelistUser(memorers);
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = 1;
        IERC20(payToken).approve(address(nftContract), whitelistMintPrice_);
        uint256 balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        nftContract.whitelistMint(mintAmount);
        uint256 balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        assert(balanceAfter == balanceBefore + mintAmount);
        vm.stopPrank();
    }

    function testRandomUserMintsSeveralWhitelistNFTCorrectly() public {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activeWhitelistMint();
        address[] memory memorers = new address[](2);
        memorers[0] = randomUser;
        nftContract.addWhitelistUser(memorers);
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = 3;
        IERC20(payToken).approve(address(nftContract), whitelistMintPrice_ * mintAmount);
        uint256 balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        nftContract.whitelistMint(mintAmount);
        uint256 balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        assert(balanceAfter == balanceBefore + mintAmount);
        vm.stopPrank();
    }

    function testFundsReceiverGetsFundsFromWhitelistMint() public {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activeWhitelistMint();
        address[] memory memorers = new address[](2);
        memorers[0] = randomUser;
        nftContract.addWhitelistUser(memorers);
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = 3;
        IERC20(payToken).approve(address(nftContract), whitelistMintPrice_ * mintAmount);

        uint256 balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedBefore = IERC20(payToken).balanceOf(fundsReceiver_);
        nftContract.whitelistMint(mintAmount);

        uint256 balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedAfter = IERC20(payToken).balanceOf(fundsReceiver_);

        uint256 fundsInContractAfter = IERC20(payToken).balanceOf(address(nftContract));

        assert(fundsInContractAfter == 0);
        assert(balanceAfter == balanceBefore + mintAmount);
        assert(fundsReceivedAfter == fundsReceivedBefore + (whitelistMintPrice_ * mintAmount));
        vm.stopPrank();
    }

    function testRandomUserCanMintEntireCollectionWhitelist() public {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activeWhitelistMint();
        address[] memory memorers = new address[](2);
        memorers[0] = randomUser;
        nftContract.addWhitelistUser(memorers);
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = totalSupply_;
        IERC20(payToken).approve(address(nftContract), whitelistMintPrice_ * mintAmount);

        uint256 balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedBefore = IERC20(payToken).balanceOf(fundsReceiver_);
        nftContract.whitelistMint(mintAmount);

        uint256 balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedAfter = IERC20(payToken).balanceOf(fundsReceiver_);

        uint256 fundsInContractAfter = IERC20(payToken).balanceOf(address(nftContract));

        assert(fundsInContractAfter == 0);
        assert(balanceAfter == balanceBefore + mintAmount);
        assert(fundsReceivedAfter == fundsReceivedBefore + (whitelistMintPrice_ * mintAmount));
        vm.stopPrank();
    }

    function testRandomUserCanNotMintMoreThanTotalSupplyWhitelist() public {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activeWhitelistMint();
        address[] memory memorers = new address[](2);
        memorers[0] = randomUser;
        nftContract.addWhitelistUser(memorers);
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = totalSupply_ + 1;
        IERC20(payToken).approve(address(nftContract), whitelistMintPrice_ * mintAmount);

        vm.expectRevert("Sold out");
        nftContract.whitelistMint(mintAmount);

        
        vm.stopPrank();
    }

    function testUserCanMintPublicAndThenMintWhitelist() public {
        // WhitelisMint
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activeWhitelistMint();
        address[] memory memorers = new address[](2);
        memorers[0] = randomUser;
        nftContract.addWhitelistUser(memorers);
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = 2;
        IERC20(payToken).approve(address(nftContract), whitelistMintPrice_ * mintAmount);

        uint256 balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedBefore = IERC20(payToken).balanceOf(fundsReceiver_);
        nftContract.whitelistMint(mintAmount);

        uint256 balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedAfter = IERC20(payToken).balanceOf(fundsReceiver_);

        uint256 fundsInContractAfter = IERC20(payToken).balanceOf(address(nftContract));

        assert(fundsInContractAfter == 0);
        assert(balanceAfter == balanceBefore + mintAmount);
        assert(fundsReceivedAfter == fundsReceivedBefore + (whitelistMintPrice_ * mintAmount));
        vm.stopPrank();

        // PublicMint
        vm.startPrank(owner_);
        nftContract.desactivateWhitelistMint();
        nftContract.activePublicMint();
        vm.stopPrank();

        vm.startPrank(randomUser);
        mintAmount = 3;
        IERC20(payToken).approve(address(nftContract), publicMintPrice_ * mintAmount);

        balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        fundsReceivedBefore = IERC20(payToken).balanceOf(fundsReceiver_);
        nftContract.mintPublic(mintAmount);

        balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        fundsReceivedAfter = IERC20(payToken).balanceOf(fundsReceiver_);

        fundsInContractAfter = IERC20(payToken).balanceOf(address(nftContract));

        assert(fundsInContractAfter == 0);
        assert(balanceAfter == balanceBefore + mintAmount);
        assert(fundsReceivedAfter == fundsReceivedBefore + (publicMintPrice_ * mintAmount));
        vm.stopPrank();
    }

    function testDifferentUsersCanMintPublicAndWhitelist() public {
        // WhitelisMint
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activeWhitelistMint();
        address[] memory memorers = new address[](2);
        memorers[0] = randomUser;
        nftContract.addWhitelistUser(memorers);
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = 2;
        IERC20(payToken).approve(address(nftContract), whitelistMintPrice_ * mintAmount);

        uint256 balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedBefore = IERC20(payToken).balanceOf(fundsReceiver_);
        nftContract.whitelistMint(mintAmount);

        uint256 balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedAfter = IERC20(payToken).balanceOf(fundsReceiver_);

        uint256 fundsInContractAfter = IERC20(payToken).balanceOf(address(nftContract));

        assert(fundsInContractAfter == 0);
        assert(balanceAfter == balanceBefore + mintAmount);
        assert(fundsReceivedAfter == fundsReceivedBefore + (whitelistMintPrice_ * mintAmount));
        vm.stopPrank();

        // PublicMint
        vm.startPrank(owner_);
        nftContract.desactivateWhitelistMint();
        nftContract.activePublicMint();
        vm.stopPrank();

        vm.startPrank(randomUser2);
        mintAmount = 3;
        IERC20(payToken).approve(address(nftContract), publicMintPrice_ * mintAmount);

        balanceBefore = IERC721(nftContract).balanceOf(randomUser2);
        fundsReceivedBefore = IERC20(payToken).balanceOf(fundsReceiver_);
        nftContract.mintPublic(mintAmount);

        balanceAfter = IERC721(nftContract).balanceOf(randomUser2);
        fundsReceivedAfter = IERC20(payToken).balanceOf(fundsReceiver_);

        fundsInContractAfter = IERC20(payToken).balanceOf(address(nftContract));

        assert(fundsInContractAfter == 0);
        assert(balanceAfter == balanceBefore + mintAmount);
        assert(fundsReceivedAfter == fundsReceivedBefore + (publicMintPrice_ * mintAmount));
        vm.stopPrank();
    }

    function test2RandomUsersCanMintPublic() external {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activePublicMint();
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = totalSupply_ - 1;
        IERC20(payToken).approve(address(nftContract), publicMintPrice_ * mintAmount);

        uint256 balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedBefore = IERC20(payToken).balanceOf(fundsReceiver_);
        nftContract.mintPublic(mintAmount);

        uint256 balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedAfter = IERC20(payToken).balanceOf(fundsReceiver_);

        uint256 fundsInContractAfter = IERC20(payToken).balanceOf(address(nftContract));

        assert(fundsInContractAfter == 0);
        assert(balanceAfter == balanceBefore + mintAmount);
        assert(fundsReceivedAfter == fundsReceivedBefore + (publicMintPrice_ * mintAmount));
        vm.stopPrank();

        vm.startPrank(randomUser2);
        mintAmount = 1;
        IERC20(payToken).approve(address(nftContract), publicMintPrice_ * mintAmount);

        balanceBefore = IERC721(nftContract).balanceOf(randomUser2);
        fundsReceivedBefore = IERC20(payToken).balanceOf(fundsReceiver_);
        nftContract.mintPublic(mintAmount);

        balanceAfter = IERC721(nftContract).balanceOf(randomUser2);
        fundsReceivedAfter = IERC20(payToken).balanceOf(fundsReceiver_);

        fundsInContractAfter = IERC20(payToken).balanceOf(address(nftContract));

        assert(fundsInContractAfter == 0);
        assert(balanceAfter == balanceBefore + mintAmount);
        assert(fundsReceivedAfter == fundsReceivedBefore + (publicMintPrice_ * mintAmount));
        vm.stopPrank();
    }

    function test2RandomUsersCanNotMintPublicIfSoldOut() external {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activePublicMint();
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = totalSupply_;
        IERC20(payToken).approve(address(nftContract), publicMintPrice_ * mintAmount);

        uint256 balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedBefore = IERC20(payToken).balanceOf(fundsReceiver_);
        nftContract.mintPublic(mintAmount);

        uint256 balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedAfter = IERC20(payToken).balanceOf(fundsReceiver_);

        uint256 fundsInContractAfter = IERC20(payToken).balanceOf(address(nftContract));

        assert(fundsInContractAfter == 0);
        assert(balanceAfter == balanceBefore + mintAmount);
        assert(fundsReceivedAfter == fundsReceivedBefore + (publicMintPrice_ * mintAmount));
        vm.stopPrank();

        vm.startPrank(randomUser2);
        mintAmount = 1;
        IERC20(payToken).approve(address(nftContract), publicMintPrice_ * mintAmount);

        vm.expectRevert("Sold out");
        nftContract.mintPublic(mintAmount);

        vm.stopPrank();
    }

    function test2RandomUsersCanMintWhitelist() external {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activeWhitelistMint();
        address[] memory memorers = new address[](2);
        memorers[0] = randomUser;
        memorers[1] = randomUser2;
        nftContract.addWhitelistUser(memorers);
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = totalSupply_ - 1;
        IERC20(payToken).approve(address(nftContract), whitelistMintPrice_ * mintAmount);

        uint256 balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedBefore = IERC20(payToken).balanceOf(fundsReceiver_);
        nftContract.whitelistMint(mintAmount);

        uint256 balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedAfter = IERC20(payToken).balanceOf(fundsReceiver_);

        uint256 fundsInContractAfter = IERC20(payToken).balanceOf(address(nftContract));

        assert(fundsInContractAfter == 0);
        assert(balanceAfter == balanceBefore + mintAmount);
        assert(fundsReceivedAfter == fundsReceivedBefore + (whitelistMintPrice_ * mintAmount));
        vm.stopPrank();

        vm.startPrank(randomUser2);
        mintAmount = 1;
        IERC20(payToken).approve(address(nftContract), whitelistMintPrice_ * mintAmount);

        balanceBefore = IERC721(nftContract).balanceOf(randomUser2);
        fundsReceivedBefore = IERC20(payToken).balanceOf(fundsReceiver_);
        nftContract.whitelistMint(mintAmount);

        balanceAfter = IERC721(nftContract).balanceOf(randomUser2);
        fundsReceivedAfter = IERC20(payToken).balanceOf(fundsReceiver_);

        fundsInContractAfter = IERC20(payToken).balanceOf(address(nftContract));

        assert(fundsInContractAfter == 0);
        assert(balanceAfter == balanceBefore + mintAmount);
        assert(fundsReceivedAfter == fundsReceivedBefore + (whitelistMintPrice_ * mintAmount));
        vm.stopPrank();
    }

    function test2RandomUsersCanNotMintWhitelistIfSoldOut() external {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activeWhitelistMint();
        address[] memory memorers = new address[](2);
        memorers[0] = randomUser;
        memorers[1] = randomUser2;
        nftContract.addWhitelistUser(memorers);
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = totalSupply_;
        IERC20(payToken).approve(address(nftContract), whitelistMintPrice_ * mintAmount);

        uint256 balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedBefore = IERC20(payToken).balanceOf(fundsReceiver_);
        nftContract.whitelistMint(mintAmount);

        uint256 balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        uint256 fundsReceivedAfter = IERC20(payToken).balanceOf(fundsReceiver_);

        uint256 fundsInContractAfter = IERC20(payToken).balanceOf(address(nftContract));

        assert(fundsInContractAfter == 0);
        assert(balanceAfter == balanceBefore + mintAmount);
        assert(fundsReceivedAfter == fundsReceivedBefore + (whitelistMintPrice_ * mintAmount));
        vm.stopPrank();

        vm.startPrank(randomUser2);
        mintAmount = 1;
        IERC20(payToken).approve(address(nftContract), whitelistMintPrice_ * mintAmount);

        balanceBefore = IERC721(nftContract).balanceOf(randomUser2);
        fundsReceivedBefore = IERC20(payToken).balanceOf(fundsReceiver_);

        vm.expectRevert("Sold out");
        nftContract.whitelistMint(mintAmount);

        vm.stopPrank();
    }

    function testTokenUriHasBeenSetCorrectly() public {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activePublicMint();
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = 1;
        IERC20(payToken).approve(address(nftContract), publicMintPrice_);
        uint256 balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        nftContract.mintPublic(mintAmount);
        uint256 balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        assert(balanceAfter == balanceBefore + mintAmount);

        uint256 tokenId = 0;
        string memory tokenUri = nftContract.tokenURI(tokenId);
        console.log("tokenUri", tokenUri);
        vm.stopPrank();
    }

    function testTokenUriHasBeenSetCorrectlyForSeveral() public {
        vm.startPrank(owner_);
        nftContract.unPauseContract();
        nftContract.activePublicMint();
        vm.stopPrank();

        vm.startPrank(randomUser);
        uint256 mintAmount = 3;
        IERC20(payToken).approve(address(nftContract), publicMintPrice_ * mintAmount);
        uint256 balanceBefore = IERC721(nftContract).balanceOf(randomUser);
        nftContract.mintPublic(mintAmount);
        uint256 balanceAfter = IERC721(nftContract).balanceOf(randomUser);
        assert(balanceAfter == balanceBefore + mintAmount);

        uint256 tokenId = 0;
        string memory tokenUri = nftContract.tokenURI(tokenId);
        console.log("tokenUri", tokenUri);

        tokenId = 1;
        tokenUri = nftContract.tokenURI(tokenId);
        console.log("tokenUri", tokenUri);

        tokenId = 2;
        tokenUri = nftContract.tokenURI(tokenId);
        console.log("tokenUri", tokenUri);
        vm.stopPrank();
    }
    
}