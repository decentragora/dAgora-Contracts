// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/Vm.sol";
import {dAgoraMemberships} from "../src/dAgoraMemberships.sol";
import {TestDAI} from "../src/mock/testDAI.sol";
import {Token} from "../src/mock/token.sol";
import {ChainLink} from "../src/mock/linkToken.sol";
import {MockOperator} from "../src/mock/mockOperator.sol";
import {SigUtils} from "../src/mock/sigUtils.sol";


contract RenewMembershipTests is Test {
    address dAgoraTreasury = address(0x1337);
    address public bob;
    address public minter;
    address public alice;
    address carol = address(0x133704);
    address dave = address(0x133705);
    address eve = address(0x133706);
    address frank = address(0x133707);
    address grace = address(0x133708);
    address harry = address(0x133709);
    address ida = address(0x133710);
    address jake = address(0x133711);
    address kate = address(0x133712);
    address luke = address(0x133713);
    address molly = address(0x133714);
    address nancy = address(0x133715);

    dAgoraMemberships dAgora;
    ChainLink link;
    MockOperator operator;
    TestDAI dai;
    SigUtils sigUtils;

    uint256 oracleFee = 1 * 10 ** 17;
    uint256 ecceliaePrice = 0;
    uint256 dagorianPrice = 50 * 10 ** 18;
    uint256 hoplitePrice = 80 * 10 ** 18;
    uint256 periclesiaPrice = 1000 * 10 ** 18;
    uint256 monthlyPrice = 5 * 10 ** 18;
    uint256 _deadline = block.timestamp + 600;

    uint256 public bobKeys = 0xB0B;
    uint256 public minterKeys = 0xB0BdA7;
    uint256 public aliceKeys = 0xA1C3;

    bytes32 public jobId = "3950";

    function setUp() public {
        bob = vm.addr(bobKeys);
        minter = vm.addr(minterKeys);
        alice = vm.addr(aliceKeys);
        link = new ChainLink();
        vm.startPrank(dAgoraTreasury);
        dai = new TestDAI();

        sigUtils = new SigUtils(dai.DOMAIN_SEPARATOR());

        link._mint();
        operator = new MockOperator(address(link));

        link.transfer(address(operator), 100);
        dAgora = new dAgoraMemberships(
                'ipfs://BaseURIOrCID/',
                address(dai),
                address(dAgoraTreasury),
                '3433',
                3950,
                address(link),
                address(operator),
                jobId,
                oracleFee
            );

        dAgora.togglePaused();
        vm.stopPrank();

        vm.startPrank(bob);
        dai._mint();
        vm.stopPrank();
    }

    function testRenewMembershipTier1_DAI() public {
        //User Mint's A Membership
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + dagorianPrice;
 
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.mintdAgoraianTier(
            1, 
            _deadline, 
            v, 
            r, 
            s
        );

        dAgora.membershipExpiresIn(1);
        dAgora.isValidMembership(1);
        dAgora.checkTokenTier(1);
        vm.warp(111111);
        dAgora.membershipExpiresIn(1);
        uint256 renewCost = ((5 ether) * 4);
        uint256 renewDeadline = block.timestamp + 600;
        
        SigUtils.Permit memory renewPermit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: renewCost,
            nonce: dAgora.nonces(address(bob)),
            deadline: renewDeadline
        });

        bytes32 renewDigest = sigUtils.getTypedDataHash(renewPermit);


        (uint8 renewV, bytes32 renewR, bytes32 renewS) = vm.sign(bobKeys, renewDigest);

        dAgora.renewMembership(
            1, 
            4, 
            renewDeadline, 
            renewV, 
            renewR, 
            renewS
        );

        dAgora.membershipExpiresIn(1);
        vm.stopPrank();
    }

    function testRenewMembershipTier2_DAI() public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + hoplitePrice;

        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);
        
        dAgora.mintHoptileTier(
            1,
            _deadline,
            v,
            r,
            s
        );

        dAgora.membershipExpiresIn(1);
        dAgora.isValidMembership(1);
        dAgora.checkTokenTier(1);
        vm.warp(111111);
        dAgora.membershipExpiresIn(1);
        uint256 renewCost = ((5 ether) * 4);
        uint256 renewDeadline = block.timestamp + 600;

        SigUtils.Permit memory renewPermit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: renewCost,
            nonce: dAgora.nonces(address(bob)),
            deadline: renewDeadline
        });

        bytes32 renewDigest = sigUtils.getTypedDataHash(renewPermit);

        (uint8 renewV, bytes32 renewR, bytes32 renewS) = vm.sign(bobKeys, renewDigest);

        dAgora.renewMembership(
            1,
            4,
            renewDeadline,
            renewV,
            renewR,
            renewS
        );
        dAgora.membershipExpiresIn(1);
        vm.stopPrank();
    }

    function testOwnerRenewMembershipTier3_DAI() public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + periclesiaPrice;
        
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.mintPericlesiaTier(
            1,
            _deadline,
            v,
            r,
            s
        );

        dAgora.membershipExpiresIn(1);
        dAgora.isValidMembership(1);
        dAgora.checkTokenTier(1);
        vm.warp(111111);
        dAgora.membershipExpiresIn(1);
        uint256 renewCost = ((5 ether) * 4);
        uint256 renewDeadline = block.timestamp + 600;
                
        SigUtils.Permit memory renewPermit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: renewCost,
            nonce: dAgora.nonces(address(bob)),
            deadline: renewDeadline
        });

        bytes32 renewDigest = sigUtils.getTypedDataHash(renewPermit);

        (uint8 renewV, bytes32 renewR, bytes32 renewS) = vm.sign(bobKeys, renewDigest);

        dAgora.renewMembership(
            1,
            4,
            renewDeadline,
            renewV,
            renewR,
            renewS
        );

        dAgora.membershipExpiresIn(1);
        vm.stopPrank();
    }

    function testDelegateRenew() public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + periclesiaPrice;
        
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.mintPericlesiaTier(
            1,
            _deadline,
            v,
            r,
            s
        );

        dAgora.membershipExpiresIn(1);
        dAgora.isValidMembership(1);
        dAgora.checkTokenTier(1);
        dAgora.addDelegatee(1, address(minter));
        vm.warp(111111);
        vm.stopPrank();
        vm.startPrank(minter);
        dai._mint();
        uint256 renewCost = ((5 ether) * 4);
        uint256 renewDeadline = block.timestamp + 600;

        SigUtils.Permit memory renewPermit = SigUtils.Permit({
            owner: address(minter),
            spender: address(dAgora),
            value: renewCost,
            nonce: dAgora.nonces(address(minter)),
            deadline: renewDeadline
        });

        bytes32 renewDigest = sigUtils.getTypedDataHash(renewPermit);

        (uint8 renewV, bytes32 renewR, bytes32 renewS) = vm.sign(minterKeys, renewDigest);

        dAgora.renewMembership(
            1,
            4,
            renewDeadline,
            renewV,
            renewR,
            renewS
        );
    }


    function testRenewExpiredToken_DAI() public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + periclesiaPrice;
        
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.mintPericlesiaTier(
            1,
            _deadline,
            v,
            r,
            s
        );

        dAgora.membershipExpiresIn(1);
        dAgora.isValidMembership(1);
        dAgora.checkTokenTier(1);
        vm.warp(2778400);
        dAgora.membershipExpiresIn(1);
        dAgora.isValidMembership(1);
        uint256 renewCost = ((5 ether) * 4);
        uint256 renewDeadline = block.timestamp + 600;

        SigUtils.Permit memory renewPermit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: renewCost,
            nonce: dAgora.nonces(address(bob)),
            deadline: renewDeadline
        });
        
        bytes32 renewDigest = sigUtils.getTypedDataHash(renewPermit);

        (uint8 renewV, bytes32 renewR, bytes32 renewS) = vm.sign(bobKeys, renewDigest);

        dAgora.renewMembership(
            1,
            4,
            renewDeadline,
            renewV,
            renewR,
            renewS
        );  

        
        dAgora.membershipExpiresIn(1);
        dAgora.isValidMembership(1);
        vm.stopPrank();
    }

    function testRenewEcclesiaToken() public {
        vm.startPrank(dAgoraTreasury);
        dAgora.giftMembership(
            address(alice),
            1,
            dAgoraMemberships.Membership(0)    
        );
        vm.stopPrank();
        vm.startPrank(alice);
        dai._mint();
        uint256 renewCost = ((5 ether) * 4);
        uint256 renewDeadline = block.timestamp + 600;

        SigUtils.Permit memory renewPermit = SigUtils.Permit({
            owner: address(alice),
            spender: address(dAgora),
            value: renewCost,
            nonce: dAgora.nonces(address(alice)),
            deadline: renewDeadline
        });

        bytes32 renewDigest = sigUtils.getTypedDataHash(renewPermit);

        (uint8 renewV, bytes32 renewR, bytes32 renewS) = vm.sign(aliceKeys, renewDigest);

        dAgora.renewMembership(
            1,
            4,
            renewDeadline,
            renewV,
            renewR,
            renewS
        );
        vm.stopPrank();
    }

    function testFailRenewMembershipNotExpiring() public {
        //User Mint's A Membership
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 4);
        uint256 price = monthlyCost + dagorianPrice;
        
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.mintdAgoraianTier(
            4,
            _deadline,
            v,
            r,
            s
        );

        dAgora.membershipExpiresIn(1);
        vm.warp(111111);
        dAgora.membershipExpiresIn(1);
        uint256 renewCost = ((5 ether) * 4);
        uint256 renewDeadline = block.timestamp + 600;

        SigUtils.Permit memory renewPermit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: renewCost,
            nonce: dAgora.nonces(address(bob)),
            deadline: renewDeadline
        });

        bytes32 renewDigest = sigUtils.getTypedDataHash(renewPermit);

        (uint8 renewV, bytes32 renewR, bytes32 renewS) = vm.sign(bobKeys, renewDigest);

        dAgora.renewMembership(
            1,
            4,
            renewDeadline,
            renewV,
            renewR,
            renewS
        );
        

        dAgora.membershipExpiresIn(1);
        vm.stopPrank();
    }

    function testFailRenewNotTokenOwnerorDelegate() public {
        vm.startPrank(bob);
        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + dagorianPrice;
        
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(bob),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(bob)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bobKeys, digest);

        dAgora.mintdAgoraianTier(
            1,
            _deadline,
            v,
            r,
            s
        );

        vm.stopPrank();
        vm.startPrank(minter);
        uint256 renewCost = ((5 ether) * 4);
        uint256 renewDeadline = block.timestamp + 600;

        SigUtils.Permit memory renewPermit = SigUtils.Permit({
            owner: address(minter),
            spender: address(dAgora),
            value: renewCost,
            nonce: dAgora.nonces(address(minter)),
            deadline: renewDeadline
        });

        bytes32 renewDigest = sigUtils.getTypedDataHash(renewPermit);

        (uint8 renewV, bytes32 renewR, bytes32 renewS) = vm.sign(minterKeys, renewDigest);

        dAgora.renewMembership(
            1,
            4,
            renewDeadline,
            renewV,
            renewR,
            renewS
        );

        vm.stopPrank();

    }

    function testFailNotEnoughFunds() public {
        vm.startPrank(dAgoraTreasury);
        dAgora.giftMembership(
            address(alice),
            1,
            dAgoraMemberships.Membership(1)    
        );
        vm.stopPrank();
        vm.startPrank(alice);
        uint256 renewCost = ((5 ether) * 4);
        uint256 renewDeadline = block.timestamp + 600;

        SigUtils.Permit memory renewPermit = SigUtils.Permit({
            owner: address(alice),
            spender: address(dAgora),
            value: renewCost,
            nonce: dAgora.nonces(address(alice)),
            deadline: renewDeadline
        });

        bytes32 renewDigest = sigUtils.getTypedDataHash(renewPermit);

        (uint8 renewV, bytes32 renewR, bytes32 renewS) = vm.sign(aliceKeys, renewDigest);

        dAgora.renewMembership(
            1,
            4,
            renewDeadline,
            renewV,
            renewR,
            renewS
        );
    }

}