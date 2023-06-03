import { expect } from "chai";
import { assert } from "console";
import e from "express";
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

describe("Test Membership Functions", function () {
    let proxy: any;
    let proxyAddress: any;
    // let DAI: any;
    let dagoraTreasury: any;
    let addr1: any;
    let addr2: any;
    let addr3: any;
    let addr4: any;
    let addr5: any;
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
        [dagoraTreasury, addr1, addr2, addr3, addr4, addr5, ...addrs] = await ethers.getSigners();
        const Dai = await ethers.getContractFactory("Dai"); //// Mock DAI contract
        // DAI = await Dai.deploy();
        // deadline = Date.now() + 1000 * 60 * 60 * 24 * 30; /// 30 days from now
        const membershipV1 = await ethers.getContractFactory("DagoraMembershipsV1");
        proxy = await upgrades.deployProxy(membershipV1, [
            'Dagora Memberships',
            'DAGORA',
            'https://decentragora.xyz/api/tokenid/',
            dagoraTreasury.address
        ]);
        await proxy.deployed();

        // get implementation address
        implementationAddress = await upgrades.erc1967.getImplementationAddress(proxy.address);
        /// set implementation address to proxy
        await proxy.setProxyAddress(proxy.address);

        ///Toggle Paused on Proxy membership state
        await proxy.connect(dagoraTreasury).togglePaused();

    });

    it("Should Mint a Dagora tier Membership", async function () {
        /// Get membership price for dagora tier for 3 months
        const price = await proxy.connect(addr1).getMintPrice(3, 1);
       

        /// Mint the membership
        await proxy.connect(addr1).mintMembership(
            1,
            3,
            { value: price }
        );
        /// Check that the membership was minted
        expect(await proxy.balanceOf(addr1.address)).to.equal(1);
        const membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(1); /// Tier
        expect(membership[1]).to.equal(addr1.address); /// Owner
        expect(membership[2]).to.equal(1);/// tokenId
        /// 30 day * 3 plus starting timestamp
        const gracePeriod = await proxy.GRACE_PERIOD();
        const exp = startingTimestamp + 7862400;
        expect(membership[3]).to.greaterThanOrEqual(exp); /// Expiration
    });

    it("Should Mint a Hoplite tier Membership", async function () {
        /// Get membership price for dagora tier for 3 months
        const price = await proxy.connect(addr1).getMintPrice(3, 2);

        /// Mint the membership
        await proxy.connect(addr1).mintMembership(
            2,
            3,
            { value: price }
        );
        /// Check that the membership was minted
        expect(await proxy.balanceOf(addr1.address)).to.equal(1);
        const membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(2); /// Tier
        expect(membership[1]).to.equal(addr1.address); /// Owner
        expect(membership[2]).to.equal(1);/// tokenId
        /// 30 day * 3 plus starting timestamp
        const gracePeriod = await proxy.GRACE_PERIOD();
        const exp = startingTimestamp + 7862400;
        expect(membership[3]).to.greaterThanOrEqual(exp); /// Expiration
    });

    it("Should Mint a Perclesian tier Membership", async function () {
        /// Get membership price for dagora tier for 3 months
        const price = await proxy.connect(addr1).getMintPrice(3, 3);
        /// Mint the membership
        await proxy.connect(addr1).mintMembership(
            3,
            3,
            { value: price }
        );
        /// Check that the membership was minted
        expect(await proxy.balanceOf(addr1.address)).to.equal(1);
        const membership = await proxy.getMembership(1);
        expect(membership[0]).to.equal(3); /// Tier
        expect(membership[1]).to.equal(addr1.address); /// Owner
        expect(membership[2]).to.equal(1);/// tokenId
        /// 30 day * 3 plus starting timestamp
        const gracePeriod = await proxy.GRACE_PERIOD();
        const exp = startingTimestamp + 7862400;
        expect(membership[3]).to.greaterThanOrEqual(exp); /// Expiration

    });

    it("Should renew a membership", async function () {
        /// Get membership price for dagora tier for 3 months
        const price = await proxy.connect(addr1).getMintPrice(1, 1);

        /// Mint the membership
        await proxy.connect(addr1).mintMembership(
            1,
            1,
            { value: price }
        );

        let membersip = await proxy.getMembership(1);
        const startingExp = membersip[3];

        /// Get membership price for dagora tier for 3 months
        const renewPrice = await proxy.getRenewalPrice(3, 1);
        console.log("renewPrice", renewPrice.toString());
       
        await proxy.connect(addr1).renewMembership(
            3,
            1,
            { value: renewPrice }
        );

        /// Check that the membership was minted
        membersip = (await proxy.getMembership(1));
        const afterExp = membersip[3];
        expect(afterExp).to.greaterThan(startingExp);
    });

    it("Should Revert if invalid tier is passed", async function () {
        /// Get membership price for dagora tier for 3 months
        const price = await proxy.connect(addr1).getMintPrice(3, 4);

        /// Mint the membership
        await expect(proxy.connect(addr1).mintMembership(
            4,
            3,
            { value: price }
        )).to.be.revertedWith("dAgoraMemberships: Invalid tier");

        await expect(proxy.connect(addr1).mintMembership(
            0,
            3,
            { value: price }
        )).to.be.revertedWith("dAgoraMemberships: Invalid tier");
    });

    it("Should Revert if invalid duration is passed", async function () {
        /// Get membership price for dagora tier for 3 months
        const price = await proxy.connect(addr1).getMintPrice(3, 1);

        /// Mint the membership
        await expect(proxy.connect(addr1).mintMembership(
            1,
            0,
            { value: price }
        )).to.be.revertedWith("dAgoraMemberships: Invalid duration");

        await expect(proxy.connect(addr1).mintMembership(
            1,
            13,
            { value: price }
        )).to.be.revertedWith("dAgoraMemberships: Invalid duration");
    });

    it("Should Revert if minter is already a member", async function () {
        /// Get membership price for dagora tier for 3 months
        const price = await proxy.connect(addr1).getMintPrice(3, 1);

        /// Mint the membership
        await proxy.connect(addr1).mintMembership(
            1,
            3,
            { value: price }
        );
        await expect(proxy.connect(addr1).mintMembership(
            1,
            3,
            { value: price }
        )).to.be.revertedWith("DagoraMemberships: Already a member");
    });

    it("Should revert if not enough eth sent", async function () {
        /// Get membership price for dagora tier for 3 months
        let price = await proxy.connect(addr1).getMintPrice(3, 1);
        const _price = price - 10;
        const sendAmount = ethers.utils.parseEther("0.024");
        /// Mint the membership
        await expect(proxy.connect(addr3).mintMembership(
            1,
            3,
            { value: sendAmount }
        )).to.be.revertedWith("dAgoraMemberships: Insufficient funds");
    });

    it("Should allow free claim to non-members", async function () {
        await proxy.connect(addr1).freeMint();
        const membership = await proxy.memberships(1);
        expect(membership[0]).to.equal(0);
        expect(membership[1]).to.equal(addr1.address);
        expect(membership[2]).to.equal(1);
    });

    it("Should revert if already a member", async function () {
        /// Get membership price for dagora tier for 3 months
        const price = await proxy.connect(addr1).getMintPrice(3, 1);

        /// Mint the membership
        await proxy.connect(addr1).mintMembership(
            1,
            3,
            { value: price }
        );

        await expect(proxy.connect(addr1).freeMint()).to.be.revertedWith("DagoraMemberships: Already a member");
    });

    it("Should allow member to cancel memebrship", async function () {
        /// Get membership price for dagora tier for 3 months
        const price = await proxy.connect(addr1).getMintPrice(3, 1);

        /// Mint the membership
        await proxy.connect(addr1).mintMembership(
            1,
            3,
            { value: price }
        );

        await proxy.connect(addr1).cancelMembership(1);
        const membership = await proxy.memberships(1);
        const gracePeriod = await proxy.GRACE_PERIOD();
        expect(membership[3]).to.greaterThanOrEqual(gracePeriod.add(startingTimestamp));
    });

    it("Should return correct view functions", async function () {
        //mint
        /// Get membership price for dagora tier for 3 months
        const price = await proxy.connect(addr1).getMintPrice(3, 1);

        /// Mint the membership
        await proxy.connect(addr1).mintMembership(
            1,
            3,
            { value: price }
        );

        const tier = await proxy.getMembershipTier(1);
        expect(tier).to.equal(1);
        const getExpiration = await proxy.getExpiration(1);
        const gracePeriod = await proxy.GRACE_PERIOD();
        const exp = startingTimestamp + 7862400;
        expect(getExpiration).to.greaterThanOrEqual(exp);

        const isValid = await proxy.isValidMembership(1);
        expect(isValid).to.equal(true);

        const isOwnerOrDelegate = await proxy.isOwnerOrDelegate(1, addr1.address);
        expect(isOwnerOrDelegate).to.equal(true);
    });

    it("Should return the correct tokenURI", async function () {
        //mint
        /// Get membership price for dagora tier for 3 months
        const price = await proxy.connect(addr1).getMintPrice(3, 1);
        
        /// Mint the membership
        await proxy.connect(addr1).mintMembership(
            1,
            3,
            { value: price }
        );
        
        const tokenURI = await proxy.tokenURI(1);
        expect(tokenURI).to.equal("https://decentragora.xyz/api/tokenid/1");
    });


    // it("Should return correct mint prices from get price functions", async function () {
    //     let price = await proxy.connect(addr1).getMintPrice(3, 0);//1 month, free tier
    //     expect(price).to.equal(ethers.utils.parseEther("0"));//// 
    //     price = await proxy.connect(addr1).getMintPrice(3, 1);//1 month, dagora tier
    //     expect(price).to.equal(ethers.utils.parseEther("65"));
    //     price = await proxy.connect(addr1).getMintPrice(3, 2);//3 month, hoplite tier
    //     /// 3 * 10 = 30 + cost of membership = 80 + 30 = 110
    //     expect(price).to.equal(ethers.utils.parseEther("110"));
    //     price = await proxy.connect(addr1).getMintPrice(3, 3);//3 month, perclesian tier
    //     /// 3 * 50 = 150 + cost of membership = 1150
    //     expect(price).to.equal(ethers.utils.parseEther("1150"));

    //     //// TEST DISCOUNTS
    //     price = await proxy.connect(addr1).getMintPrice(12, 0);//6 month, free tier
    //     expect(price).to.equal(ethers.utils.parseEther("0"));
    //     price = await proxy.connect(addr1).getMintPrice(12, 1);//1 year, dagora tier
    //     /// 12 * 5 = 60 - 5 = 55  + cost of membership 50 = 105
    //     expect(price).to.equal(ethers.utils.parseEther("105"));
    //     price = await proxy.connect(addr1).getMintPrice(12, 2);//1 year, hoplite tier
    //     /// 12 * 10 = 120 - 10 = 110 + cost of membership 80 = 190
    //     expect(price).to.equal(ethers.utils.parseEther("190"));
    //     price = await proxy.connect(addr1).getMintPrice(12, 3);//1 year, perclesian tier
    //     /// 12 * 50 = 600 - 50 = 550 + cost of membership 1000 = 1550
    //     expect(price).to.equal(ethers.utils.parseEther("1550"));
        
    // });

    // it("Should return correct renew prices from get price function", async function () {
    //     let renewalPrice = await proxy.getRenewalPrice(3, 0) // 3 months, ecclesia tier
    //     expect(renewalPrice).to.equal(ethers.utils.parseEther("15"));
    //     renewalPrice = await proxy.getRenewalPrice(3, 1) // 3 months, dagora tier
    //     /// 3 * 5 = 15 
    //     expect(renewalPrice).to.equal(ethers.utils.parseEther("15"));
    //     renewalPrice = await proxy.getRenewalPrice(3, 2) // 3 months, hoplite tier
    //     /// 3 * 10 = 30
    //     expect(renewalPrice).to.equal(ethers.utils.parseEther("30"));
    //     renewalPrice = await proxy.getRenewalPrice(3, 3) // 3 months, perclesian tier
    //     /// 3 * 50 = 150
    //     expect(renewalPrice).to.equal(ethers.utils.parseEther("150"));

    //     //// TEST DISCOUNTS Renewals
    //     renewalPrice = await proxy.getRenewalPrice(12, 0) // 1 year, ecclesia tier
    //     /// 12 * 5 = 60 - 5 = 55
    //     expect(renewalPrice).to.equal(ethers.utils.parseEther("55"));
    //     renewalPrice = await proxy.getRenewalPrice(12, 1) // 1 year, dagora tier
    //     /// 12 * 5 = 60 - 5 = 55
    //     expect(renewalPrice).to.equal(ethers.utils.parseEther("55"));
    //     renewalPrice = await proxy.getRenewalPrice(12, 2) // 1 year, hoplite tier
    //     /// 12 * 10 = 120 - 10 = 110
    //     expect(renewalPrice).to.equal(ethers.utils.parseEther("110"));
    //     renewalPrice = await proxy.getRenewalPrice(12, 3) // 1 year, perclesian tier
    //     /// 12 * 50 = 600 - 50 = 550
    //     expect(renewalPrice).to.equal(ethers.utils.parseEther("550"));
    // });

    it("Membership should be soulbound to owner", async function () {
        /// Get membership price for dagora tier for 3 months
        const price = await proxy.connect(addr1).getMintPrice(3, 1);

        /// Mint the membership
        await proxy.connect(addr1).mintMembership(
            1,
            3,
            { value: price }
        );

        const owner = await proxy.ownerOf(1);
        expect(owner).to.equal(addr1.address);

        await expect(proxy.connect(addr1).transferFrom(addr1.address, addr2.address, 1)).to.be.revertedWith("dAgoraMemberships: Soulbound membership");
    });

    it("Should revert if contract is paused", async function () {
        /// Get membership price for dagora tier for 3 months
        const price = await proxy.connect(addr1).getMintPrice(3, 2);

        /// Pause the contract
        await proxy.connect(dagoraTreasury).togglePaused();

        /// Mint the membership
        await expect(proxy.connect(addr1).mintMembership(
            3,
            3,
            { value: price }
        )).to.be.revertedWith("DagoraMemberships: Contract is paused");
        await expect(proxy.connect(addr1).freeMint()).to.be.revertedWith("DagoraMemberships: Contract is paused");

        /// Unpause the contract
        await proxy.connect(dagoraTreasury).togglePaused();
        await proxy.connect(addr1).mintMembership(
            2,
            3,
            { value: price }
        );
        
        // pause the contract again
        await proxy.connect(dagoraTreasury).togglePaused();
        
        /// upgrade the membership

        const upgradePrice = await proxy.connect(addr1)._getUpgradePrice(1, 2, 3);

        await expect(proxy.connect(addr1).upgradeMembership(
            3,
            2,
            1,
            { value: upgradePrice },
        )).to.be.revertedWith("DagoraMemberships: Contract is paused");
            
        /// renew the membership
        const renewalPrice = await proxy.connect(addr1).getRenewalPrice(3, 2);

        await expect(proxy.connect(addr1).renewMembership(
            3,
            1,
            { value: renewalPrice }
        )).to.be.revertedWith("DagoraMemberships: Contract is paused");
        
        /// cancel the membership
        await expect(proxy.connect(addr1).cancelMembership(1)).to.be.revertedWith("DagoraMemberships: Contract is paused");


        /// Unpause the contract
        await proxy.connect(dagoraTreasury).togglePaused();

        // upgrade the membership
        await proxy.connect(addr1).upgradeMembership(
            3,
            2,
            1,
            { value: upgradePrice },
        );

        /// pause the contract again
        await proxy.connect(dagoraTreasury).togglePaused();

        /// test delegate funcs
        await expect(proxy.connect(addr1).addDelegate(addr2.address, 1)).to.be.revertedWith("DagoraMemberships: Contract is paused");
        // unpause the contract
        await proxy.connect(dagoraTreasury).togglePaused();
        await proxy.connect(addr1).addDelegate(addr2.address, 1);
        // pause the contract again
        await proxy.connect(dagoraTreasury).togglePaused();

        await expect(proxy.connect(addr1).removeDelegate(addr2.address, 1, 0)).to.be.revertedWith("DagoraMemberships: Contract is paused");
        await expect(proxy.connect(addr2).swapDelegate(1, addr2.address, addr3.address)).to.be.revertedWith("DagoraMemberships: Contract is paused");
    });


    it("Should revert if  invalid tier is passed", async function () {
        await expect(proxy.connect(dagoraTreasury).giftMembership(addr2.address, 4, 1)).to.be.revertedWith("dAgoraMemberships: Invalid tier");
    });

    it("Should return the tokenId that the address owns", async function () {
        await proxy.connect(dagoraTreasury).giftMembership(addr1.address, 0, 1);
        await proxy.connect(dagoraTreasury).giftMembership(addr2.address, 1, 1);
        await proxy.connect(dagoraTreasury).giftMembership(addr3.address, 2, 1);
        await proxy.connect(dagoraTreasury).giftMembership(addr4.address, 3, 1);

        const query = await proxy.addressTokenIds(addr1.address);
        expect(query).to.equal(1);
        const query2 = await proxy.addressTokenIds(addr2.address);
        expect(query2).to.equal(2);
        const query3 = await proxy.addressTokenIds(addr3.address);
        expect(query3).to.equal(3);
        const query4 = await proxy.addressTokenIds(addr4.address);
        expect(query4).to.equal(4);
        const query5 = await proxy.addressTokenIds(addr5.address);
        expect(query5).to.equal(0); 
    });


});

