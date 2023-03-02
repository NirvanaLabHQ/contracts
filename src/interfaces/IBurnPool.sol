// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

interface IBurnPool {
    error ZeroRebornTokenSet();
    error ZeroOwnerSet();

    event Deposit(uint256 amount);

    event Burn(uint256 amount);

    // deposit $REBORN for burn
    function deposit(uint256 amount) external;

    // burn expect amount of $REBORN
    function burn(uint256 amount) external;

    // burn all $REBORN of current pool
    function burnAll() external;
}
