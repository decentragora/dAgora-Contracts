import { expect } from "chai";
import { assert } from "console";
import { ethers, upgrades } from "hardhat";


describe("Test Dagora ERC20", function () {
    let proxy: any;
    let proxyAddress: any;
    let factory: any;
    let factoryAddress: any;
    let factoryProxy: any;
    let factoryProxyAddress: any;
    let DagoraERC20: any;
    let token: any;
    let _maxSupply: any;
    let initSupply: any;
    let tokenAddress: any;
    let deployedAddress: any;
    let DAI: any;
    let dagoraTreasury: any;
    let addr1: any;
    let addr2: any;
    let addr3: any;
    let addr4: any;
    let addrs: any;
    let startTimeStamp: any;
    let leaves: any;
    let tree: any;
    let root: any;
    let implementationAddress: any;
    let implementation: any;

    beforeEach(async function () {
        [dagoraTreasury, addr1, addr2, addr3, addr4, ...addrs] = await ethers.getSigners();

        // Get starting timestamp
        startTimeStamp = Math.floor(Date.now() / 1000);
        //Deploy DAI
        const Dai = await ethers.getContractFactory("Dai");
        DAI = await Dai.deploy();
        await DAI.deployed();

        //Deploy Membership Proxy
        const membership = await ethers.getContractFactory("DagoraMembershipsV1");
        proxy = await upgrades.deployProxy(membership, [
            'Dagora Memberships',
            'DAGORA',
            'https://dagora.io/memberships/',
            dagoraTreasury.address,
            DAI.address
        ]);
        await proxy.deployed();
        proxyAddress = proxy.address;



        DagoraERC20 = await ethers.getContractFactory("DagoraERC20");

        const factory = await ethers.getContractFactory("DagoraERC20Factory");
        factoryProxy = await upgrades.deployProxy(factory, [proxy.address]);
        await factoryProxy.deployed();
        factoryProxyAddress = factoryProxy.address;

        await factoryProxy.togglePaused();

        await DAI.mint();
        await DAI.connect(addr1).mint();
        await DAI.connect(addr2).mint();
        // Gift membership to addr1 for 3 months
        await proxy.connect(dagoraTreasury).giftMembership(addr1.address, 1, 3);
        expect(await proxy.ownerOf(1)).to.equal(addr1.address);
        let _membership = await proxy.getMembership(1);
        expect(_membership[0]).to.equal(1);
        expect(_membership[1]).to.equal(addr1.address);
        expect(_membership[2]).to.equal(1);

        _maxSupply = ethers.utils.parseUnits('100000', 18);
        initSupply = ethers.utils.parseUnits('1000', 18);
        const tx = await factoryProxy.connect(addr1).createDagoraERC20(
            'Test Token',
            'TEST',
            addr1.address,
            initSupply,
            _maxSupply,
            1
        );
        const receipt = await tx.wait();
        const nftAddress = await factoryProxy.getUserContracts(addr1.address);
        assert(nftAddress != factoryAddress, "NFT Address is the same as the factory address");
        assert(nftAddress != proxyAddress, "NFT Address is the same as the proxy address");
        assert(nftAddress != dagoraTreasury.address, "NFT Address is the same as the treasury address");
        assert(nftAddress != addr1.address, "NFT Address is the same as the addr1 address");
        
        token = DagoraERC20.attach(nftAddress[0]);
        const name = await token.name();
        const symbol = await token.symbol();
        const owner = await token.owner();
        const totalSupply = await token.totalSupply();
        const maxSupply = await token.maxSupply();
        const balance = await token.balanceOf(addr1.address);
        expect(name).to.equal('Test Token');
        expect(symbol).to.equal('TEST');
        expect(owner).to.equal(addr1.address);
        expect(totalSupply).to.equal(ethers.utils.parseUnits('1000', 18));
        expect(maxSupply).to.equal(ethers.utils.parseUnits('100000', 18));
    });

    it("have correct name set", async function () {
        expect(await token.name()).to.equal('Test Token');
    });

    it("Should allow Owner to Mint tokens", async function () {
        await token.connect(addr1).mint(addr1.address, ethers.utils.parseUnits('1000', 18));
        expect(await token.balanceOf(addr1.address)).to.equal(ethers.utils.parseUnits('2000', 18));
    });

    it("Should not allow non-Owner to Mint tokens", async function () {
        await expect(token.connect(addr2).mint(addr2.address, ethers.utils.parseUnits('1000', 18))).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Should enforce maxSupply", async function () {
        const maxSupply = await token.maxSupply();
        await expect(token.connect(addr1).mint(addr1.address, maxSupply + 1)).to.be.revertedWith("dAgoraERC20: max supply reached");
    });

    it("Should not allow mint to zero address", async function () {
        await expect(token.connect(addr1).mint(ethers.constants.AddressZero, ethers.utils.parseUnits('1000', 18))).to.be.revertedWith("dAgoraERC20: mint to the zero address");
    });

    it("Should allow Owner to Burn tokens", async function () {
        await token.connect(addr1).burn(addr1.address, ethers.utils.parseUnits('1000', 18));
        expect(await token.balanceOf(addr1.address)).to.equal(0);
    });

    it("Should not allow non-Owner to Burn tokens", async function () {
        await expect(token.connect(addr2).burn(addr1.address, ethers.utils.parseUnits('1000', 18))).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Should allow Owner to set new Owner", async function () {
        await token.connect(addr1).transferOwnership(addr2.address);
        expect(await token.owner()).to.equal(addr2.address);
    });

    it("Should not allow non-Owner to set new Owner", async function () {
        await expect(token.connect(addr2).transferOwnership(addr3.address)).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Should allow owner to toggle Paused", async function () {
        expect(await token.isPaused()).to.equal(false);
        await token.connect(addr1).togglePaused();
        expect(await token.isPaused()).to.equal(true);
        await token.connect(addr1).togglePaused();
        expect(await token.isPaused()).to.equal(false);
    });

    it("Should not allow non-Owner to toggle Paused", async function () {
        await expect(token.connect(addr2).togglePaused()).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Should not allow non Owner to toggle paused on the factory contract", async function () {
        await expect(factoryProxy.connect(addr2).togglePaused()).to.be.revertedWith("Ownable: caller is not the owner");
        expect(await factoryProxy.isPaused()).to.equal(false);
    });

    it("Should allow owner to set min tier to create contract", async function (){
        expect(await factoryProxy.minERC20Tier()).to.equal(0);
        await factoryProxy.setMinERC20Tier(1);
        expect(await factoryProxy.minERC20Tier()).to.equal(1);
    }); 

    it("Should not allow non-Owner to set min tier to create contract", async function (){
        expect(await factoryProxy.minERC20Tier()).to.equal(0);
        await expect(factoryProxy.connect(addr2).setMinERC20Tier(1)).to.be.revertedWith("Ownable: caller is not the owner");
        expect(await factoryProxy.minERC20Tier()).to.equal(0);
    });

    it("Should not allow transfer when contract is paused", async function (){
        await token.connect(addr1).togglePaused();
        await expect(token.connect(addr1).transfer(addr2.address, ethers.utils.parseUnits('1000', 18))).to.be.revertedWith("dAgoraERC20: token transfer paused");
    });

});        
