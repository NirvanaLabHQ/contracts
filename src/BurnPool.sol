// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

// import "src/interface/IBurnPool.sol";
// import {IRewardVault} from "src/interfaces/IRewardVault.sol";
import {IBurnPool} from "src/interfaces/IBurnPool.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function burn(uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract BurnPool is IBurnPool, Ownable {
    IERC20 rebornToken;

    constructor(address owner_, address rebornToken_) {
        if (owner_ == address(0)) {
            revert ZeroOwnerSet();
        }

        if (rebornToken_ == address(0)) {
            revert ZeroRebornTokenSet();
        }

        _transferOwnership(owner_);
        rebornToken = IERC20(rebornToken_);
    }

    /**
     * @inheritdoc IBurnPool
     */
    function deposit(uint256 amount) external override onlyOwner {
        rebornToken.transferFrom(msg.sender, address(this), amount);

        emit Deposit(amount);
    }

    function burn(uint256 amount) external override onlyOwner {
        rebornToken.burn(amount);

        emit Burn(amount);
    }

    function burnAll() external override onlyOwner {
        rebornToken.burn(rebornToken.balanceOf(address(this)));
    }
}
