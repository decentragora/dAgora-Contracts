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

contract MintMembershipsTest is Test {
    address dAgoraTreasury = address(0x1337);
    // address signer = address(0x133702);
    address public bob;
    address public minter;
    address alice = address(0x133703);
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

    
    uint256 public bobKeys = 0xB0B;
    uint256 public minterKeys = 0xB0BdA7;

    dAgoraMemberships dAgora;
    ChainLink link;
    MockOperator operator;
    TestDAI dai;
    Token token;
    SigUtils sigUtils;


    uint256 oracleFee = 1 * 10 ** 17;
    uint256 ecceliaePrice = 0;
    uint256 dagorianPrice = 50 * 10 ** 18;
    uint256 hoplitePrice = 80 * 10 ** 18;
    uint256 periclesiaPrice = 1000 * 10 ** 18;
    uint256 monthlyPrice = 5 * 10 ** 18;
    uint256 _deadline = block.timestamp + 600;
    

    bytes32 public jobId =
        0xf7f77ea15719ea30bd2a584962ab273b1116f0e70fe80bbb0b30557d0addb7f3;

    function setUp() public {
        link = new ChainLink();
        vm.startPrank(dAgoraTreasury);
        dai = new TestDAI();
        token = new Token();
        bob = vm.addr(bobKeys);
        minter = vm.addr(minterKeys);

        link._mint();
        operator = new MockOperator(address(link));

        sigUtils = new SigUtils(dai.DOMAIN_SEPARATOR());

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
            1, // month
            _deadline, // deadline for Tx
            v,
            r,
            s
        );

        vm.stopPrank();
    }

    function testDelegates() public {
        vm.startPrank(bob);
        
        dAgora.addDelegatee(
            1,
            address(alice)
        );
        address[] memory delegates = dAgora.checkTokenDelegates(1);
        console.log(delegates[0]);

        dAgora.addDelegatee(
            1,
            address(carol)
        );
        delegates = dAgora.checkTokenDelegates(1);
        console.log(delegates[0]);
        vm.stopPrank();
    }

    function testSwapDelegate() public {
        vm.startPrank(bob);

        dAgora.addDelegatee(
            1,
            address(alice)
        );
        address[] memory delegates = dAgora.checkTokenDelegates(1);
        delegates = dAgora.checkTokenDelegates(1);
        console.log(delegates[0]);

        dAgora.swapDelegate(
            1,
            address(alice),
            address(carol)
        );

        delegates = dAgora.checkTokenDelegates(1);
        console.log(delegates[0]);

    }
    
    function testRemoveDelegate() public {
        vm.startPrank(bob);

        dAgora.addDelegatee(
            1,
            address(alice)
        );
        address[] memory delegates = dAgora.checkTokenDelegates(1);
        delegates = dAgora.checkTokenDelegates(1);
        console.log(delegates[0]);

        dAgora.removeDelegatee(
            1,
            address(alice),
            0
        );

        delegates = dAgora.checkTokenDelegates(1);

    }

    function testRemove10thAddress() public {
        vm.startPrank(bob);
        dAgora.addDelegatee(
            1,
            address(alice)
        );
        dAgora.addDelegatee(
            1,
            address(carol)
        );
        dAgora.addDelegatee(
            1,
            address(dave)
        );
        dAgora.addDelegatee(
            1,
            address(eve)
        );
        dAgora.addDelegatee(
            1,
            address(frank)
        );
        dAgora.addDelegatee(
            1,
            address(grace)
        );
        dAgora.addDelegatee(
            1,
            address(harry)
        );
        dAgora.addDelegatee(
            1,
            address(ida)
        );
        dAgora.addDelegatee(
            1,
            address(jake)
        );
        dAgora.addDelegatee(
            1,
            address(kate)
        );

        address[] memory delegates = dAgora.checkTokenDelegates(1);

        dAgora.removeDelegatee(
            1,
            address(kate),
            9
        );
    
        delegates = dAgora.checkTokenDelegates(1);

        dAgora.addDelegatee(
            1,
            address(luke)
        );

        delegates = dAgora.checkTokenDelegates(1);

        vm.stopPrank();
    }

    function testDelegateRewnew() public {
        console.log(dAgora.membershipExpiresIn(1));
        vm.startPrank(bob);
        dAgora.addDelegatee(
            1,
            address(minter)
        );
        vm.stopPrank();

        vm.startPrank(minter);
        dai._mint();
        uint256 monthlyCost = ((5 ether) * 11);
        uint256 price = monthlyCost;

        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(minter),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(minter)),
            deadline: _deadline
        });


        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(minterKeys, digest);

        dAgora.renewMembership(
            1,
            12,
            _deadline,
            v,
            r,
            s
        );

        console.log(dAgora.membershipExpiresIn(1));
    }

    function testFailNotPerclesia() public {
        vm.startPrank(minter);
        dai._mint();

        uint256 monthlyCost = ((5 ether) * 1);
        uint256 price = monthlyCost + dagorianPrice;
       
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: address(minter),
            spender: address(dAgora),
            value: price,
            nonce: dAgora.nonces(address(minter)),
            deadline: _deadline
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(minterKeys, digest);

        dAgora.mintdAgoraianTier(
            1, // month
            _deadline, // deadline for Tx
            v,
            r,
            s
        );

        dAgora.addDelegatee(
            2,
            address(bob)
        );
    }

    function testFailNotOwnerOfToken() public {
        vm.startPrank(alice);
        dAgora.addDelegatee(
            1,
            address(bob)
        );
    }

    function testFail11Delegates() public {
        vm.startPrank(bob);
        dAgora.addDelegatee(
            1,
            address(alice)
        );
        dAgora.addDelegatee(
            1,
            address(carol)
        );
        dAgora.addDelegatee(
            1,
            address(dave)
        );
        dAgora.addDelegatee(
            1,
            address(eve)
        );
        dAgora.addDelegatee(
            1,
            address(frank)
        );
        dAgora.addDelegatee(
            1,
            address(grace)
        );
        dAgora.addDelegatee(
            1,
            address(harry)
        );
        dAgora.addDelegatee(
            1,
            address(ida)
        );
        dAgora.addDelegatee(
            1,
            address(jake)
        );
        dAgora.addDelegatee(
            1,
            address(kate)
        );
        dAgora.addDelegatee(
            1,
            address(luke)
        );

        address[] memory delegates = dAgora.checkTokenDelegates(1);
    }
}