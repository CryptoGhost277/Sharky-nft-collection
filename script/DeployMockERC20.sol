// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {MockERC20} from "../src/MockERC20.sol";

contract DeployMockERC20 is Script {
    function run() external returns (MockERC20) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        string memory name_ = "MockERC20";
        string memory symbol_ = "MERC20";

        MockERC20 mockERC20 = new MockERC20(name_, symbol_);

        vm.stopBroadcast();
        return mockERC20;
    }

}