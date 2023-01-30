// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {DeployProxy} from "foundry-upgrades/utils/DeployProxy.sol";

import "src/RebornPortal.sol";
import {RBT} from "src/RBT.sol";
import {IRebornDefination} from "src/interfaces/IRebornPortal.sol";

import {ECDSAUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";

contract TokenTest is Test, IRebornDefination {
    RebornPortal portal;
    RBT rbt;
    DeployProxy internal _deployProxy;
    address owner = vm.addr(2);
    address user = vm.addr(10);
    // solhint-disable-next-line var-name-mixedcase
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
    bytes32 _TYPE_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    function setUp() public {
        // deploy portal
        portal = new RebornPortal();
        _deployProxy = new DeployProxy();
        RebornPortal portalImpl = new RebornPortal();
        rbt = deployRBT();
        bytes memory initData = abi.encodeWithSelector(
            RebornPortal.initialize.selector,
            address(rbt),
            0.1 * 1 ether,
            0x00000000000004200000000000064210,
            owner
        );
        portal = RebornPortal(
            _deployProxy.deployErc1967Proxy(address(portalImpl), initData)
        );
    }

    function deployRBT() public returns (RBT token) {
        RBT tokenImpl = new RBT();
        bytes memory initData = abi.encodeWithSelector(
            RBT.initialize.selector,
            "REBORN",
            "RBT",
            10**10 * 1 ether,
            owner
        );
        token = RBT(
            _deployProxy.deployErc1967Proxy(address(tokenImpl), initData)
        );
    }

    function testTalantPrice() public {
        assertEq(portal.talentPrice(TALANT.Degen), 0);
        assertEq(portal.talentPrice(TALANT.Gifted), 2 ether);
        assertEq(portal.talentPrice(TALANT.Genius), 4 ether);
    }

    function testPropertiesPrice() public {
        assertEq(portal.propertiesPrice(PROPERTIES.BASIC), 0);
        assertEq(portal.propertiesPrice(PROPERTIES.C), 1 ether);
        assertEq(portal.propertiesPrice(PROPERTIES.B), 2 ether);
        assertEq(portal.propertiesPrice(PROPERTIES.A), 4 ether);
        assertEq(portal.propertiesPrice(PROPERTIES.S), 6 ether);
    }

    /**
     * @dev core process of incarnate
     */
    function testIncarnateWithPermit() public {
        uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        uint256 deadline = block.timestamp + 100;
        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                user,
                address(portal),
                MAX_INT,
                0,
                deadline
            )
        );

        bytes32 domainSeparator = keccak256(
            abi.encode(
                _TYPE_HASH,
                keccak256(abi.encodePacked(rbt.name())),
                keccak256("1"),
                block.chainid,
                address(rbt)
            )
        );

        bytes32 hash = ECDSAUpgradeable.toTypedDataHash(
            domainSeparator,
            structHash
        );

        // sign
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(10, hash);

        hoax(user);
        // rbt.permit(user, address(portal), MAX_INT, deadline, v, r, s);
        bytes memory callData = abi.encodeWithSignature(
            "incarnate((uint8,uint8),uint256,uint256,bytes32,bytes32,uint8)",
            Innate(
                IRebornDefination.TALANT.Degen,
                IRebornDefination.PROPERTIES.BASIC
            ),
            MAX_INT,
            deadline,
            r,
            s,
            v
        );
        payable(address(portal)).call{value: 0.1 * 1 ether}(callData);
    }
}
