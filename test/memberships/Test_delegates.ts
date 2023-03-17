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

describe("Test Membership delegate Functions", function () {
    let proxy: any;
    let proxyAddress: any;
    let DAI: any;
    let dagoraTreasury: any;
    let addr1: any;
    let addr2: any;
    let addr3: any;
    let addr4: any;
    let addr5: any;
    let addr6: any;
    let addr7: any;
    let addr8: any;
    let addr9: any;
    let addr10: any;
    let addr11: any;
    let addr12: any;
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
        [dagoraTreasury, addr1, addr2, addr3, addr4, addr5, addr6, addr7, addr8, addr9, addr10, addr11, addr12, ...addrs] = await ethers.getSigners();
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
        /// set implementation address to proxy
        await proxy.setProxyAddress(proxy.address);

        await DAI.connect(addr1).mint()
        await DAI.connect(addr2).mint();

        ///Toggle Paused on Proxy membership state
        await proxy.connect(dagoraTreasury).togglePaused();

    });


    it("should not allow ecclesia members to delegate", async function () {
        /// Mint membership
        await proxy.connect(addr1).freeMint();
        /// Try to delegate
        await expect(proxy.connect(addr1).addDelegate(addr2.address, 1)).to.be.revertedWith("DagoraMemberships: Only Percelsia members can delegate");
    });

    it("Should not allow dagorian members to delegate", async function () {
        /// Mint membership
        const price = await proxy.getMintPrice(1, 1);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } =  await ethers.utils.splitSignature(sig);    
        await proxy.connect(addr1).mintMembership(
            1,
            1,
            deadline,
            proxy.address,
            v,
            r,
            s
        );

        /// Try to delegate
        await expect(proxy.connect(addr1).addDelegate(addr2.address, 1)).to.be.revertedWith("DagoraMemberships: Only Percelsia members can delegate");
    });

    it("Should not allow Hoplite members to delegate", async function () {
        /// Mint membership
        const price = await proxy.getMintPrice(1, 2);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } =  await ethers.utils.splitSignature(sig);    
        await proxy.connect(addr1).mintMembership(
            2,
            1,
            deadline,
            proxy.address,
            v,
            r,
            s
        );

        /// Try to delegate
        await expect(proxy.connect(addr1).addDelegate(addr2.address, 1)).to.be.revertedWith("DagoraMemberships: Only Percelsia members can delegate");
    });

    it("Should allow Perclesian members to delegate", async function () {
        /// Mint membership
        const price = await proxy.getMintPrice(1, 3);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } =  await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).mintMembership(
            3,
            1,
            deadline,
            proxy.address,
            v,
            r,
            s
        );
        
        /// Try to delegate
        await proxy.connect(addr1).addDelegate(addr2.address, 1);
        const delegates = await proxy.getTokenDelegates(1);
        expect(delegates[0]).to.equal(addr2.address);
    });

    it("Should allow a owner to swap delegates", async function () {
        /// Mint membership
        const price = await proxy.getMintPrice(1, 3);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } =  await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).mintMembership(
            3,
            1,
            deadline,
            proxy.address,
            v,
            r,
            s
        );

        /// Try to delegate
        await proxy.connect(addr1).addDelegate(addr2.address, 1);
        const delegates = await proxy.getTokenDelegates(1);
        expect(delegates[0]).to.equal(addr2.address);

        /// Try to swap delegates
        await proxy.connect(addr1).swapDelegate(1, addr2.address, addr3.address);
        const newDelegates = await proxy.getTokenDelegates(1);
        expect(newDelegates[0]).to.equal(addr3.address);
    });

    it("Should not allow a non-owner to swap delegates", async function () {
        /// Mint membership
        const price = await proxy.getMintPrice(1, 3);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } =  await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).mintMembership(
            3,
            1,
            deadline,
            proxy.address,
            v,
            r,
            s
        );

        /// Try to delegate
        await proxy.connect(addr1).addDelegate(addr2.address, 1);
        const delegates = await proxy.getTokenDelegates(1);
        expect(delegates[0]).to.equal(addr2.address);

        /// Try to swap delegates
        await expect(proxy.connect(addr2).swapDelegate(1, addr2.address, addr3.address)).to.be.revertedWith("dAgoraMemberships: Only controller");
    });

    it("Should allow a owner to remove delegates", async function () {
        /// Mint membership
        const price = await proxy.getMintPrice(1, 3);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } =  await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).mintMembership(
            3,
            1,
            deadline,
            proxy.address,
            v,
            r,
            s
        );
            
        /// Try to delegate
        await proxy.connect(addr1).addDelegate(addr2.address, 1);
        const delegates = await proxy.getTokenDelegates(1);
        expect(delegates[0]).to.equal(addr2.address);

        /// Try to remove delegates
        await proxy.connect(addr1).removeDelegate(addr2.address, 1, 0);
        const newDelegates = await proxy.getTokenDelegates(1);
        expect(newDelegates.length).to.equal(0);
    });

    it("Should not allow a non-owner to remove delegates", async function () {
        /// Mint membership
        const price = await proxy.getMintPrice(1, 3);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } =  await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).mintMembership(
            3,
            1,
            deadline,
            proxy.address,
            v,
            r,
            s
        );

        /// Try to delegate
        await proxy.connect(addr1).addDelegate(addr2.address, 1);
        const delegates = await proxy.getTokenDelegates(1);
        expect(delegates[0]).to.equal(addr2.address);

        /// Try to remove delegates
        await expect(proxy.connect(addr2).removeDelegate(addr2.address, 1, 0)).to.be.revertedWith("dAgoraMemberships: Only controller");
    });

    it("Should allow Perclesian members to delegate to multiple addresses", async function () {
        /// Mint membership
        const price = await proxy.getMintPrice(1, 3);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } =  await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).mintMembership(
            3,
            1,
            deadline,
            proxy.address,
            v,
            r,
            s
        );

        /// Try to delegate 10 times
        for (let i: any = 2; i < 12; i++) {
            let address = await ethers.getSigner(i);
            await proxy.connect(addr1).addDelegate(address.address, 1);
        }
        const delegates = await proxy.getTokenDelegates(1);
        for (let i: any = 2; i < 12; i++) {
            let address = await ethers.getSigner(i);
            expect(delegates[i-2]).to.equal(address.address);
        }
    });

    it("Should not allow a delegate to delegate", async function () {
        /// Mint membership
        const price = await proxy.getMintPrice(1, 3);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } =  await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).mintMembership(
            3,
            1,
            deadline,
            proxy.address,
            v,
            r,
            s
        );

        /// Try to delegate
        await proxy.connect(addr1).addDelegate(addr2.address, 1);
        const delegates = await proxy.getTokenDelegates(1);
        expect(delegates[0]).to.equal(addr2.address);

        /// Try to delegate from delegate
        await expect(proxy.connect(addr2).addDelegate(addr3.address, 1)).to.be.revertedWith("dAgoraMemberships: Only controller");
    });

    it("Should not allow a delegate to remove delegates", async function () {
        /// Mint membership
        const price = await proxy.getMintPrice(1, 3);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } =  await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).mintMembership(
            3,
            1,
            deadline,
            proxy.address,
            v,
            r,
            s
        );

        /// Try to delegate
        await proxy.connect(addr1).addDelegate(addr2.address, 1);
        const delegates = await proxy.getTokenDelegates(1);
        expect(delegates[0]).to.equal(addr2.address);
        
        /// Try to remove delegates
        await expect(proxy.connect(addr2).removeDelegate(addr2.address, 1, 0)).to.be.revertedWith("dAgoraMemberships: Only controller");
    });

    it("Should not allow owner to delegate to themselves", async function () {
        /// Mint membership
        const price = await proxy.getMintPrice(1, 3);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } =  await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).mintMembership(
            3,
            1,
            deadline,
            proxy.address,
            v,
            r,
            s
        );

        /// Try to delegate
        await proxy.connect(addr1).addDelegate(addr2.address, 1);
        const delegates = await proxy.getTokenDelegates(1);
        expect(delegates[0]).to.equal(addr2.address);
        
        /// Try to remove delegates
        await expect(proxy.connect(addr1).addDelegate(addr1.address, 1)).to.be.revertedWith("dAgoraMemberships: Cannot delegate to self");
    });

    it("Should not allow owner to delegate to zero address", async function () {
        /// Mint membership
        const price = await proxy.getMintPrice(1, 3);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } =  await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).mintMembership(
            3,
            1,
            deadline,
            proxy.address,
            v,
            r,
            s
        );

        /// Try to delegate
        await proxy.connect(addr1).addDelegate(addr2.address, 1);
        const delegates = await proxy.getTokenDelegates(1);
        expect(delegates[0]).to.equal(addr2.address);
        
        /// Try to remove delegates
        await expect(proxy.connect(addr1).addDelegate(ethers.constants.AddressZero, 1)).to.be.revertedWith("dAgoraMemberships: Cannot delegate to address(0)");
    });

    it("Should not allow owner to delegate to a address that is already delegated", async function () {
        /// Mint membership
        const price = await proxy.getMintPrice(1, 3);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } =  await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).mintMembership(
            3,
            1,
            deadline,
            proxy.address,
            v,
            r,
            s
        );
        
        /// Try to delegate
        await proxy.connect(addr1).addDelegate(addr2.address, 1);
        const delegates = await proxy.getTokenDelegates(1);
        expect(delegates[0]).to.equal(addr2.address);

        /// Try to delegate to same address
        await expect(proxy.connect(addr1).addDelegate(addr2.address, 1)).to.be.revertedWith("dAgoraMemberships: Delegatee is already included");
    });


    it("Should allow a delegate to renew membership", async function () {
        /// Mint membership
        const price = await proxy.getMintPrice(1, 3);
        const sig = await getPermitSignature(addr1, DAI, proxy.address, price, deadline);
        const { v, r, s } =  await ethers.utils.splitSignature(sig);
        await proxy.connect(addr1).mintMembership(
            3,
            1,
            deadline,
            proxy.address,
            v,
            r,
            s
        );

        let membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(3);
        expect(membership[1]).to.equal(addr1.address);
        expect(membership[2]).to.equal(1);
        let InitSubTime = membership[3];
        
        /// Try to delegate
        await proxy.connect(addr1).addDelegate(addr2.address, 1);
        const delegates = await proxy.getTokenDelegates(1);
        expect(delegates[0]).to.equal(addr2.address);

        /// Mint membership
        const renewPrice = await proxy.getRenewalPrice(3, 3);
        const renewSig = await getPermitSignature(addr2, DAI, proxy.address, renewPrice, deadline);
        const { v: renewV, r: renewR, s: renewS } =  await ethers.utils.splitSignature(renewSig);

        await proxy.connect(addr2).renewMembership(
            3,
            1,
            deadline,
            proxy.address,
            renewV,
            renewR,
            renewS
        );
        membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(3);
        expect(membership[1]).to.equal(addr1.address);
        expect(membership[2]).to.equal(1);
        let RenewSubTime = membership[3];
        expect(InitSubTime).to.be.lessThan(RenewSubTime);
    });

    
});