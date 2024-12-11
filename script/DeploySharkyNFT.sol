// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {SharkyNFTContract} from "../src/SharkyNFTContract.sol";

contract DeploySharkyNFT is Script {
    function run() external returns (SharkyNFTContract) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        string memory name_ = "Sharky World NFT";
        string memory symbol_ = "SHRK";
        string memory baseUri_ = "to be defined"; // DEFINIRLO
        uint256 publicMintPrice_ = 20; // Confirm this 100 ether
        uint256 whitelistMintPrice_ = 10; // Confirm this 50 ether
        uint256 totalSupply_ = 3000;
        address owner_ = 0xe371cDd686341baDbE337D21c53fA51Db505e361; // Change: set correct one
        address fundsReceiver_ = 0xe371cDd686341baDbE337D21c53fA51Db505e361; // Change: set correct one
        address admin_ = 0xe371cDd686341baDbE337D21c53fA51Db505e361; // Change: set correct one
        address payTokenAddress_ = 0xe4C7fBB0a626ed208021ccabA6Be1566905E2dFc; // Change: set correct one

        SharkyNFTContract nftContract = new SharkyNFTContract(name_, symbol_, baseUri_, publicMintPrice_, whitelistMintPrice_, totalSupply_, owner_, fundsReceiver_, admin_, payTokenAddress_);

        vm.stopBroadcast();
        return nftContract;
    }

}