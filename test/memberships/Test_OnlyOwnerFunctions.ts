import { expect } from "chai";
import { assert } from "console";
import { ethers, upgrades} from "hardhat";

describe("Test Only Owner Functions", function () {
    let proxy: any;
    let proxyAddress: any;
    let dagoraTreasury: any;
    let addr1: any;
    let addr2: any;
    let addrs: any;
    let startingTimestamp: any;

    beforeEach(async function () {
        startingTimestamp = Math.floor(Date.now() / 1000);
        [dagoraTreasury, addr1, addr2, ...addrs] = await ethers.getSigners();

        const membership = await ethers.getContractFactory("DagoraMembershipsV1");
        proxy = await upgrades.deployProxy(membership, [
            'Dagora Memberships',
            'DAGORA',
            'https://dagora.io/memberships/',
            dagoraTreasury.address,
        ]);
        await proxy.deployed();
        proxyAddress = proxy.address;
    });

    describe("Only Owner Functions", function () {
        //Gifts TODO
        it("Should allow owner to gift membership", async function () {
            expect(await proxy.balanceOf(addr1.address)).to.equal(0);
            await proxy.giftMembership(addr1.address, 1, 3);
            expect(await proxy.balanceOf(addr1.address)).to.equal(1);
            expect(await proxy.ownerOf(1)).to.equal(addr1.address);
            const membership = await proxy.memberships(1);
            expect(membership[0]).to.equal(1);
            expect(membership[1]).to.equal(addr1.address);
            expect(membership[2]).to.equal(1);
            // 30 days * 3 in seconds
            expect(membership[3]).to.greaterThan(7776000 + startingTimestamp);
        });

        // Gift Membership - should not allow non-owner
        it("Should not allow non-owner to gift membership", async function () {
            expect(await proxy.balanceOf(addr1.address)).to.equal(0);
            await expect(proxy.connect(addr1).giftMembership(addr1.address, 1, 3)).to.be.revertedWith('Ownable: caller is not the owner');
            expect(await proxy.balanceOf(addr1.address)).to.equal(0);
        });

        // Gift Membership - should not allow to gift membership to 0 address
        it("Should not allow to gift membership to 0 address", async function () {
            expect(await proxy.balanceOf(addr1.address)).to.equal(0);
            await expect(proxy.giftMembership(ethers.constants.AddressZero, 1, 3)).to.be.revertedWith('DagoraMemberships: cannot gift to 0 address');
            expect(await proxy.balanceOf(addr1.address)).to.equal(0);
        });

        // Gift Upgrade 
        it("Should allow owner to gift upgrade", async function () {
            expect(await proxy.balanceOf(addr1.address)).to.equal(0);
            await proxy.giftMembership(addr1.address, 1, 3);
            expect(await proxy.balanceOf(addr1.address)).to.equal(1);
            expect(await proxy.ownerOf(1)).to.equal(addr1.address);
            let membership = await proxy.memberships(1);
            expect(membership[0]).to.equal(1);
            expect(membership[1]).to.equal(addr1.address);
            expect(membership[2]).to.equal(1);
            expect(membership[3]).to.greaterThanOrEqual(7776000 + startingTimestamp);

            await proxy.giftUpgrade(1, 2);
            expect(await proxy.balanceOf(addr1.address)).to.equal(1);
            expect(await proxy.ownerOf(1)).to.equal(addr1.address);
            membership = await proxy.memberships(1);
            expect(membership[0]).to.equal(2);
        });     

        // Gift Upgrade - should not allow non-owner
        it("Should not allow non-owner to gift upgrade", async function () {
            expect(await proxy.balanceOf(addr1.address)).to.equal(0);
            await proxy.giftMembership(addr1.address, 1, 3);
            expect(await proxy.balanceOf(addr1.address)).to.equal(1);
            expect(await proxy.ownerOf(1)).to.equal(addr1.address);
            let membership = await proxy.memberships(1);
            expect(membership[0]).to.equal(1);
            expect(membership[1]).to.equal(addr1.address);
            expect(membership[2]).to.equal(1);
            expect(membership[3]).to.greaterThanOrEqual(7776000 + startingTimestamp);

            await expect(proxy.connect(addr1).giftUpgrade(1, 2)).to.be.revertedWith('Ownable: caller is not the owner');
            expect(await proxy.balanceOf(addr1.address)).to.equal(1);
            expect(await proxy.ownerOf(1)).to.equal(addr1.address);
            membership = await proxy.memberships(1);
            expect(membership[0]).to.equal(1);
        });


        // Gift Upgrade - should not allow 0 tier
        it("Should not allow 0 tier", async function () {
            expect(await proxy.balanceOf(addr1.address)).to.equal(0);
            await proxy.giftMembership(addr1.address, 1, 3);
            expect(await proxy.balanceOf(addr1.address)).to.equal(1);
            expect(await proxy.ownerOf(1)).to.equal(addr1.address);
            let membership = await proxy.memberships(1);
            expect(membership[0]).to.equal(1);
            expect(membership[1]).to.equal(addr1.address);
            expect(membership[2]).to.equal(1);
            expect(membership[3]).to.greaterThanOrEqual(7776000 + startingTimestamp);

            await expect(proxy.giftUpgrade(1, 0)).to.be.revertedWith('dAgoraMemberships: Invalid tier');
            expect(await proxy.balanceOf(addr1.address)).to.equal(1);
            expect(await proxy.ownerOf(1)).to.equal(addr1.address);
            membership = await proxy.memberships(1);
            expect(membership[0]).to.equal(1);
        });

        // Gift Upgrade - should not allow 4 tier
        it("Should not allow 4 tier", async function () {
            expect(await proxy.balanceOf(addr1.address)).to.equal(0);
            await proxy.giftMembership(addr1.address, 1, 3);
            expect(await proxy.balanceOf(addr1.address)).to.equal(1);
            expect(await proxy.ownerOf(1)).to.equal(addr1.address);
            let membership = await proxy.memberships(1);
            expect(membership[0]).to.equal(1);
            expect(membership[1]).to.equal(addr1.address);
            expect(membership[2]).to.equal(1);
            expect(membership[3]).to.greaterThanOrEqual(7776000 + startingTimestamp);

            await expect(proxy.giftUpgrade(1, 4)).to.be.revertedWith('dAgoraMemberships: Invalid tier');
            expect(await proxy.balanceOf(addr1.address)).to.equal(1);
            expect(await proxy.ownerOf(1)).to.equal(addr1.address);
            membership = await proxy.memberships(1);
            expect(membership[0]).to.equal(1);
        });

        // Gift Upgrade - should not allow to upgrade to same tier
        it("Should not allow to upgrade to same tier", async function () {
            expect(await proxy.balanceOf(addr1.address)).to.equal(0);
            await proxy.giftMembership(addr1.address, 1, 3);
            expect(await proxy.balanceOf(addr1.address)).to.equal(1);
            expect(await proxy.ownerOf(1)).to.equal(addr1.address);
            let membership = await proxy.memberships(1);
            expect(membership[0]).to.equal(1);
            expect(membership[1]).to.equal(addr1.address);
            expect(membership[2]).to.equal(1);
            expect(membership[3]).to.greaterThanOrEqual(7776000 + startingTimestamp);

            await expect(proxy.giftUpgrade(1, 1)).to.be.revertedWith('dAgoraMemberships: Invalid tier');
            expect(await proxy.balanceOf(addr1.address)).to.equal(1);
            expect(await proxy.ownerOf(1)).to.equal(addr1.address);
            membership = await proxy.memberships(1);
            expect(membership[0]).to.equal(1);
        });

        //Gift Renewal
        it("Should allow owner to gift renewal", async function () {
            expect(await proxy.balanceOf(addr1.address)).to.equal(0);
            await proxy.giftMembership(addr1.address, 1, 3);
            expect(await proxy.balanceOf(addr1.address)).to.equal(1);
            expect(await proxy.ownerOf(1)).to.equal(addr1.address);
            let membership = await proxy.memberships(1);
            expect(membership[0]).to.equal(1);
            expect(membership[1]).to.equal(addr1.address);
            expect(membership[2]).to.equal(1);
            expect(membership[3]).to.greaterThanOrEqual(7776000 + startingTimestamp);

            await proxy.giftExtension(1, 3);
            expect(await proxy.balanceOf(addr1.address)).to.equal(1);
            expect(await proxy.ownerOf(1)).to.equal(addr1.address);
            membership = await proxy.memberships(1);
            expect(membership[0]).to.equal(1);
            expect(membership[1]).to.equal(addr1.address);
            expect(membership[2]).to.equal(1);
            expect(membership[3]).to.greaterThanOrEqual(7776000 + 7776000 + 86400 + startingTimestamp );
        });

        // Toggle Paused
        it("Should allow owner to toggle Paused state", async function () {
            expect(await proxy.isPaused()).to.equal(true);
            await proxy.togglePaused();
            expect(await proxy.isPaused()).to.equal(false);
        });

        // Toggle Paused - should not allow non-owner
        it("Should not allow non-owner to toggle Paused state", async function () {
            expect(await proxy.isPaused()).to.equal(true);
            await expect(proxy.connect(addr1).togglePaused()).to.be.revertedWith('Ownable: caller is not the owner');
            expect(await proxy.isPaused()).to.equal(true);
        });

        // setBaseURI
        it("Should allow owner to set baseURI", async function () {
            expect(await proxy.baseURI()).to.equal('https://dagora.io/memberships/');
            await proxy.setBaseURI('https://dagora.io/memberships/v2/');
            expect(await proxy.baseURI()).to.equal('https://dagora.io/memberships/v2/');
        });

        // setBaseURI - should not allow non-owner
        it("Should not allow non-owner to set baseURI", async function () {
            expect(await proxy.baseURI()).to.equal('https://dagora.io/memberships/');
            await expect(proxy.connect(addr1).setBaseURI('https://dagora.io/memberships/v2/')).to.be.revertedWith('Ownable: caller is not the owner');
            expect(await proxy.baseURI()).to.equal('https://dagora.io/memberships/');
        });

        // setDiscount
        it("Should allow owner to set discount", async function () {
            expect(await proxy.discount()).to.equal(ethers.utils.parseEther('0.0026'));
            await proxy.setDiscount(ethers.utils.parseEther('10'));
            expect(await proxy.discount()).to.equal(ethers.utils.parseEther('10'));
        });

            // ecclesiaRenewPrice = 2600000000000000 || 0.0026 ETH;
    // dagorianPrice = 26000000000000000 || 0.026 ETH;
    // dagoraRenewPrice = 2600000000000000 || 0.0026 ETH;
    // hoplitePrice = 42000000000000000 || 0.042 ETH;
    // hopliteRenewPrice = 5200000000000000 || 0.0052 ETH;
    // percelsiaPrice = 520000000000000000 || 0.52 ETH;
    // percelsiaRenewPrice = 26000000000000000 || 0.026 ETH;
    // discount = 2600000000000000 || 0.0026 ETH;

        // setDiscount - should not allow non-owner
        it("Should not allow non-owner to set discount", async function () {
            expect(await proxy.discount()).to.equal(ethers.utils.parseEther('0.0026'));
            await expect(proxy.connect(addr1).setDiscount(10)).to.be.revertedWith('Ownable: caller is not the owner');
            expect(await proxy.discount()).to.equal(2600000000000000);
        });

        // setPercelsiaPrice
        it("Should allow owner to set Percelsia price", async function () {
            expect(await proxy.percelsiaPrice()).to.equal(ethers.utils.parseEther('0.52'));
            await proxy.setPercelsiaPrice(ethers.utils.parseEther('100'));
            expect(await proxy.percelsiaPrice()).to.equal(ethers.utils.parseEther('100'));
        });

        // setPercelsiaPrice - should not allow non-owner
        it("Should not allow non-owner to set Percelsia price", async function () {
            expect(await proxy.percelsiaPrice()).to.equal(ethers.utils.parseEther('0.52'));
            await expect(proxy.connect(addr1).setPercelsiaPrice(ethers.utils.parseEther('100'))).to.be.revertedWith('Ownable: caller is not the owner');
            expect(await proxy.percelsiaPrice()).to.equal(ethers.utils.parseEther('0.52'));
        });

        // setHoplitePrice
        it("Should allow owner to set Hoplite price", async function () {
            expect(await proxy.hoplitePrice()).to.equal(ethers.utils.parseEther('0.042'));
            await proxy.setHoplitePrice(ethers.utils.parseEther('100'));
            expect(await proxy.hoplitePrice()).to.equal(ethers.utils.parseEther('100'));
        });

        // setHoplitePrice - should not allow non-owner
        it("Should not allow non-owner to set Hoplite price", async function () {
            expect(await proxy.hoplitePrice()).to.equal(ethers.utils.parseEther('0.042'));
            await expect(proxy.connect(addr1).setHoplitePrice(ethers.utils.parseEther('1000'))).to.be.revertedWith('Ownable: caller is not the owner');
            expect(await proxy.hoplitePrice()).to.equal(ethers.utils.parseEther('0.042'));
        });

        // setDagorianPrice
        it("Should allow owner to set Dagorian price", async function () {
            expect(await proxy.dagorianPrice()).to.equal(ethers.utils.parseEther('0.026'));
            await proxy.setDagorianPrice(ethers.utils.parseEther('1000'));
            expect(await proxy.dagorianPrice()).to.equal(ethers.utils.parseEther('1000'));
        });

        // setDagorianPrice - should not allow non-owner
        it("Should not allow non-owner to set Dagorian price", async function () {
            expect(await proxy.dagorianPrice()).to.equal(ethers.utils.parseEther('0.026'));
            await expect(proxy.connect(addr1).setDagorianPrice(ethers.utils.parseEther('1000'))).to.be.revertedWith('Ownable: caller is not the owner');
            expect(await proxy.dagorianPrice()).to.equal(ethers.utils.parseEther('0.026'));
        });

        // setEcclesiaPrice
        it("Should allow owner to set Ecclesia price", async function () {
            expect(await proxy.ecclesiaPrice()).to.equal(0);
            await proxy.setEcclesiaPrice(ethers.utils.parseEther('1000'));
            expect(await proxy.ecclesiaPrice()).to.equal(ethers.utils.parseEther('1000'));
        });

        // setEcclesiaPrice - should not allow non-owner
        it("Should not allow non-owner to set Ecclesia price", async function () {
            expect(await proxy.ecclesiaPrice()).to.equal(ethers.utils.parseEther('0'));
            await expect(proxy.connect(addr1).setEcclesiaPrice(ethers.utils.parseEther('1000'))).to.be.revertedWith('Ownable: caller is not the owner');
            expect(await proxy.ecclesiaPrice()).to.equal(ethers.utils.parseEther('0'));
        });

    // ecclesiaRenewPrice = 2600000000000000 || 0.0026 ETH;
    // dagorianPrice = 26000000000000000 || 0.026 ETH;
    // dagoraRenewPrice = 2600000000000000 || 0.0026 ETH;
    // hoplitePrice = 42000000000000000 || 0.042 ETH;
    // hopliteRenewPrice = 5200000000000000 || 0.0052 ETH;
    // percelsiaPrice = 520000000000000000 || 0.52 ETH;
    // percelsiaRenewPrice = 26000000000000000 || 0.026 ETH;
    // discount = 2600000000000000 || 0.0026 ETH;
        // setPercelsiaRenewPrice
        it("Should allow owner to set Percelsia renew price", async function () {
            expect(await proxy.percelsiaRenewPrice()).to.equal(ethers.utils.parseEther('0.026'));
            await proxy.setPercelsiaRenewPrice(ethers.utils.parseEther('100'));
            expect(await proxy.percelsiaRenewPrice()).to.equal(ethers.utils.parseEther('100'));
        });

        // setPercelsiaRenewPrice - should not allow non-owner
        it("Should not allow non-owner to set Percelsia renew price", async function () {
            expect(await proxy.percelsiaRenewPrice()).to.equal(ethers.utils.parseEther('0.026'));
            await expect(proxy.connect(addr1).setPercelsiaRenewPrice(ethers.utils.parseEther('100'))).to.be.revertedWith('Ownable: caller is not the owner');
            expect(await proxy.percelsiaRenewPrice()).to.equal(ethers.utils.parseEther('0.026'));
        });

        // setHopliteRenewPrice
        it("Should allow owner to set Hoplite renew price", async function () {
            expect(await proxy.hopliteRenewPrice()).to.equal(5200000000000000);
            await proxy.setHopliteRenewPrice(ethers.utils.parseEther('100'));
            expect(await proxy.hopliteRenewPrice()).to.equal(ethers.utils.parseEther('100'));
        });

        // setHopliteRenewPrice - should not allow non-owner
        it("Should not allow non-owner to set Hoplite renew price", async function () {
            expect(await proxy.hopliteRenewPrice()).to.equal(5200000000000000);
            await expect(proxy.connect(addr1).setHopliteRenewPrice(ethers.utils.parseEther('1000'))).to.be.revertedWith('Ownable: caller is not the owner');
            expect(await proxy.hopliteRenewPrice()).to.equal(5200000000000000);
        });

        // setDagorianRenewPrice
        it("Should allow owner to set Dagorian renew price", async function () {
            expect(await proxy.dagoraRenewPrice()).to.equal(2600000000000000);
            await proxy.setDagorianRenewPrice(ethers.utils.parseEther('1000'));
            expect(await proxy.dagoraRenewPrice()).to.equal(ethers.utils.parseEther('1000'));
        });

        // setDagorianRenewPrice - should not allow non-owner
        it("Should not allow non-owner to set Dagorian renew price", async function () {
            expect(await proxy.dagoraRenewPrice()).to.equal(2600000000000000);
            await expect(proxy.connect(addr1).setDagorianRenewPrice(ethers.utils.parseEther('1000'))).to.be.revertedWith('Ownable: caller is not the owner');
            expect(await proxy.dagoraRenewPrice()).to.equal(2600000000000000);
        });
        
        // setDagoraTreasury
        it("Should allow owner to set Dagora treasury", async function () {
            expect(await proxy.dagoraTreasury()).to.equal(dagoraTreasury.address);
            await proxy.setDagoraTreasury(addr2.address);
            expect(await proxy.dagoraTreasury()).to.equal(addr2.address);
        });

        // setDagoraTreasury - should not allow non-owner
        it("Should not allow non-owner to set Dagora treasury", async function () {
            expect(await proxy.dagoraTreasury()).to.equal(dagoraTreasury.address);
            await expect(proxy.connect(addr2).setDagoraTreasury(addr2.address)).to.be.revertedWith('Ownable: caller is not the owner');
            expect(await proxy.dagoraTreasury()).to.equal(dagoraTreasury.address);
        });

        it("Should allow owner to set the proxy address", async function () {
            await proxy.setProxyAddress(addr2.address);
            expect(await proxy.proxyImplementation()).to.equal(addr2.address);
        });

        it("Should not allow non-owner to set the proxy address", async function () {
            await expect(proxy.connect(addr2).setProxyAddress(addr2.address)).to.be.revertedWith('Ownable: caller is not the owner');
            expect(await proxy.proxyImplementation()).to.not.equal(addr2.address);
        });

        it("Should allow owner to withdraw eth from contract", async function () {
            // /// withdraw eth
            await proxy.withdrawETH();
            expect(await ethers.provider.getBalance(proxy.address)).to.equal(ethers.utils.parseEther('0'));
        });

        it("Should not allow non-owner to withdraw eth from contract", async function () {
            await expect(proxy.connect(addr2).withdrawETH()).to.be.revertedWith('Ownable: caller is not the owner');
        });

        it("Should not allow non-owner to withdraw eth from contract", async function () {
            await expect(proxy.connect(addr2).withdrawETH()).to.be.revertedWith('Ownable: caller is not the owner');
        });


 
    });

});