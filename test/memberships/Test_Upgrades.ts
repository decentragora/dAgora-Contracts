import { expect } from "chai";
import { assert } from "console";
import { ethers, upgrades} from "hardhat";


async function getPermitSignature(signer: any, token: any, spender: any, value: any, deadline: any) {
    const [nonce, name, version, chainId] = await Promise.all([
        token.nonces(signer.address),
        token.name(),
        "1",
        signer.getChainId(),
      ])
    
      return ethers.utils.splitSignature(
        await signer._signTypedData(
          {
            name,
            version,
            chainId,
            verifyingContract: token.address,
          },
          {
            Permit: [
              {
                name: "owner",
                type: "address",
              },
              {
                name: "spender",
                type: "address",
              },
              {
                name: "value",
                type: "uint256",
              },
              {
                name: "nonce",
                type: "uint256",
              },
              {
                name: "deadline",
                type: "uint256",
              },
            ],
          },
          {
            owner: signer.address,
            spender,
            value,
            nonce,
            deadline,
          }
        )
      )
}

describe("Test Membership Upgrade Functions", function () {
    let proxy: any; 
    let proxyAddress: any;
    let DAI: any;
    let dagoraTreasury: any;
    let addr1: any;
    let addr2: any;
    let addr3: any;
    let addr4: any;
    let addrs: any;
    let domain: any;
    let types: any;
    let message: any;
    let deadline: any;
    let implementationAddress: any;
    let startingTimestamp: any;


    beforeEach(async function () {
        const currentBlock = await ethers.provider.getBlockNumber();
        const blockTimestamp = (await ethers.provider.getBlock(currentBlock)).timestamp;
        startingTimestamp= blockTimestamp;
        [dagoraTreasury, addr1, addr2, addr3, addr4, ...addrs] = await ethers.getSigners();
        const Dai = await ethers.getContractFactory("Dai"); //// Mock DAI contract
        DAI = await Dai.deploy();
        deadline = Date.now() + 1000 * 60 * 60 * 24 * 30; /// 30 days from now
        const membershipV1 = await ethers.getContractFactory("DagoraMembershipsV1");
        proxy = await upgrades.deployProxy(membershipV1, [
            'Dagora Memberships',
            'DAGORA',
            'https://decentragora.xyz/api/tokenid/',
            dagoraTreasury.address,
            DAI.address
        ]);
        await proxy.deployed();

        // get implementation address
        implementationAddress = await upgrades.erc1967.getImplementationAddress(proxy.address);
        await proxy.setProxyAddress(proxy.address);
        
        await DAI.connect(addr1).mint()
        await DAI.connect(addr2).mint();

        ///Toggle Paused on Proxy membership state
        await proxy.connect(dagoraTreasury).togglePaused();

        ///Set up EIP712
        domain = {
            name: 'DAI',
            version: '1',
            chainId: 31337,
            verifyingContract: DAI.address
        };

        types = {
            Permit: [
                { name: 'owner', type: 'address' },
                { name: 'spender', type: 'address' },
                { name: 'value', type: 'uint256' },
                { name: 'nonce', type: 'uint256' },
                { name: 'deadline', type: 'uint256' },
            ]
        };

    });

    it("Should Upgrade from ecclesia tier to dagora tier", async function () {  
        await proxy.connect(addr1).freeMint();
        const membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(0);
        ///Upgrade to dagorian tier

        const price = await proxy._getUpgradePrice(1, 0, 1);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } = await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).upgradeMembership(1, 0, 1, deadline, proxy.address, v, r, s);
        const membership2 = await proxy.getMembership(1);
        expect(membership2[0]).to.equal(1);
    });

    it("Should Upgrade from Ecclesia  tier to Hoplite tier", async function () {
        await proxy.connect(addr1).freeMint();
        const membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(0);
        expect(membership[1]).to.equal(addr1.address);
        expect(membership[2]).to.equal(1);
        ///Upgrade to dagorian tier

        const price = await proxy._getUpgradePrice(1, 0, 2);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } = await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).upgradeMembership(2, 0, 1, deadline, proxy.address, v, r, s);
        // const membership2 = await proxy.getMembership(1);
        // expect(membership2[0]).to.equal(2);
    });
    
    it("Should Upgrade from Ecclesia  tier to Perclesian tier", async function () {
        await proxy.connect(addr1).freeMint();
        const membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(0);
        ///Upgrade to dagorian tier

        const price = await proxy._getUpgradePrice(1, 0, 3);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } = await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).upgradeMembership(3, 0, 1, deadline, proxy.address, v, r, s);
        const membership2 = await proxy.getMembership(1);
        expect(membership2[0]).to.equal(3);
    });

    it("Should upgrade from Dagorian tier to Hoplite tier", async function () {
        const price = await proxy.getMintPrice(3, 1);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        let { v, r, s } = await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).mintMembership(1, 3, deadline, proxy.address, v, r, s);
        const membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(1);

        const price2 = await proxy._getUpgradePrice(1, 1, 2);
        const sig2 = await getPermitSignature(addr1, DAI, proxy.address, price2, deadline);
        let { v: v2, r: r2, s: s2 } = await ethers.utils.splitSignature(sig2);
        await proxy.connect(addr1).upgradeMembership(2, 1, 1, deadline, proxy.address, v2, r2, s2);
        const membership2 = await proxy.getMembership(1);
        expect(membership2[0]).to.equal(2);
    });

    it("Should upgrade from Dagorian tier to Perclesian tier", async function () {
        const price = await proxy.getMintPrice(3, 1);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        let { v, r, s } = await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).mintMembership(1, 3, deadline, proxy.address, v, r, s);
        const membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(1);

        const price2 = await proxy._getUpgradePrice(1, 1, 3);
        const sig2 = await getPermitSignature(addr1, DAI, proxy.address, price2, deadline);
        let { v: v2, r: r2, s: s2 } = await ethers.utils.splitSignature(sig2);
        await proxy.connect(addr1).upgradeMembership(3, 1, 1, deadline, proxy.address, v2, r2, s2);
        const membership2 = await proxy.getMembership(1);
        expect(membership2[0]).to.equal(3);
    });

    it("Should upgrade from Hoplite tier to Perclesian tier", async function () {
        const price = await proxy.getMintPrice(3, 2);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        let { v, r, s } = await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).mintMembership(2, 3, deadline, proxy.address, v, r, s);
        const membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(2);
        expect(membership[2]).to.equal(1);

        const price2 = await proxy._getUpgradePrice(1, 2, 3);
        const sig2 = await getPermitSignature(addr1, DAI, proxy.address, price2, deadline);
        let { v: v2, r: r2, s: s2 } = await ethers.utils.splitSignature(sig2);
        await proxy.connect(addr1).upgradeMembership(3, 2, 1, deadline, proxy.address, v2, r2, s2);
        const membership2 = await proxy.getMembership(1);
        expect(membership2[0]).to.equal(3);
    });

    
});

