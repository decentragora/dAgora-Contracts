import { expect } from "chai";
import { assert } from "console";
import { ethers, upgrades } from "hardhat";
import MerkleTree from "merkletreejs";
import keccak256 from "keccak256";


describe("Test Power NFTA", function () {
    let proxy: any;
    let proxyAddress: any;
    let factory: any;
    let factoryAddress: any;
    let factoryProxy: any;
    let factoryProxyAddress: any;
    let PowerNFTA: any;
    let nft: any;
    let Nft: any;
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




    beforeEach(async function () {
        [dagoraTreasury, addr1, addr2, addr3, addr4, ...addrs] = await ethers.getSigners();

        // Get starting timestamp
        startTimeStamp = Math.floor(Date.now() / 1000);
        //Deploy Membership Proxy
        const membership = await ethers.getContractFactory("DagoraMembershipsV1");
        proxy = await upgrades.deployProxy(membership, [
            'Dagora Memberships',
            'DAGORA',
            'https://dagora.io/memberships/',
            dagoraTreasury.address,
        ]);
        await proxy.deployed();
        proxyAddress = proxy.address;

        PowerNFTA = await ethers.getContractFactory("PowerNFT");

        //get power code
        
        //Deploy Factory Proxy
        const factory = await ethers.getContractFactory("DagoraPowerNFTFactory");
        factoryProxy = await upgrades.deployProxy(factory, [
            proxy.address,
        ]);
        await factoryProxy.deployed();
        await factoryProxy.togglePaused();
        // Gift membership to addr1 for 3 months
        await proxy.connect(dagoraTreasury).giftMembership(addr1.address, 1, 3);
        expect(await proxy.ownerOf(1)).to.equal(addr1.address);
        let _membership = await proxy.getMembership(1);
        expect(_membership[0]).to.equal(1);
        expect(_membership[1]).to.equal(addr1.address);
        expect(_membership[2]).to.equal(1);

        const tx = await factoryProxy.connect(addr1).createPowerNFT(
            "NFTPower",
            "POWER",
            "https://test.io/nft/",
            10,
            250,
            ethers.utils.parseEther("0.1"),
            100,
            addr1.address,
            addr1.address,
            1
        );
        const receipt = await tx.wait();
        const nftAddress = await factoryProxy.getUserContracts(addr1.address);
        assert(nftAddress != factoryAddress, "NFT Address is the same as the factory address");
        assert(nftAddress != proxyAddress, "NFT Address is the same as the proxy address");
        assert(nftAddress != dagoraTreasury.address, "NFT Address is the same as the treasury address");
        assert(nftAddress != addr1.address, "NFT Address is the same as the addr1 address");
        assert(nftAddress != PowerNFTA.address, "NFT Address is the same as the NFTAPlus address");
        nft = PowerNFTA.attach(nftAddress[0]);
        deployedAddress = nftAddress[0];
        const name = await nft.name();
        const symbol = await nft.symbol();
        const uri = await nft.baseURI();
        const bulkBuyLimit = await nft.bulkBuyLimit();
        const price = await nft.mintPrice();
        const maxSupply = await nft.maxSupply();
        const owner = await nft.owner();
        const royalty = await nft.royaltyInfo(1, ethers.utils.parseEther("1"));
        expect(royalty[0]).to.equal(addr1.address);
        const amount = royalty[1];
        expect(royalty[1]).to.equal(amount);
        expect(name).to.equal("NFTPower");
        expect(symbol).to.equal("POWER");
        expect(uri).to.equal("https://test.io/nft/");
        expect(bulkBuyLimit).to.equal(10);
        expect(price).to.equal(ethers.utils.parseEther("0.1"));
        expect(maxSupply).to.equal(100);
        expect(owner).to.equal(addr1.address);
    });

        // Mint functions
        it("Should Allow addr1 to Mint to bulkbuylimit", async function () {
            const limit = await nft.bulkBuyLimit();
            const mintCost = await nft.mintPrice();
            await nft.connect(addr2).mintNFT(addr2.address, limit, { value: mintCost.mul(limit) });
            expect(await nft.balanceOf(addr2.address)).to.equal(limit);
            expect(await nft.totalSupply()).to.equal(limit);
            const balanceOfContract = await ethers.provider.getBalance(nft.address);
            expect(balanceOfContract).to.equal(mintCost.mul(limit));
        });

        it("Should not Allow addr1 to Mint to over bulkbuylimit", async function () {
            const limit = await nft.bulkBuyLimit();
            const mintCost = await nft.mintPrice();
            await expect(nft.connect(addr2).mintNFT(addr2.address, limit + 1, { value: mintCost.mul(limit + 1) })).to.be.revertedWith("PowerNFT: exceeds bulk buy limit");
        });

        it("Should Allow Owner of NFTAPlus to Set Base URI", async function () {
            expect(await nft.baseURI()).to.equal("https://test.io/nft/");
            await nft.connect(addr1).setBaseURI("https://Test.com/nft/V2/");
            expect(await nft.baseURI()).to.equal("https://Test.com/nft/V2/");
        });

        it("Should not Allow Non-Owner of NFTAPlus to Set Base URI", async function () {
            expect(await nft.baseURI()).to.equal("https://test.io/nft/");
            await expect(nft.connect(addr2).setBaseURI("https://Test.com/nft/V2/")).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.baseURI()).to.equal("https://test.io/nft/");
        });

        it("Should Allow Owner of NFTAPlus to Set the Base Extension URI", async function () {
            expect(await nft.baseExtension()).to.equal(".json");
            await nft.connect(addr1).setBaseExtension(".png");
            expect(await nft.baseExtension()).to.equal(".png");
        });

        it("Should not Allow Non-Owner of NFTAPlus to Set the Base Extension URI", async function () {
            expect(await nft.baseExtension()).to.equal(".json");
            await expect(nft.connect(addr2).setBaseExtension(".png")).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.baseExtension()).to.equal(".json");
        });
    
        it("Should Allow Owner of Power NFTA to Set the Mint Price", async function () {
            expect(await nft.mintPrice()).to.equal(ethers.utils.parseEther("0.1"));
            await nft.connect(addr1).setMintPrice(ethers.utils.parseEther("0.2"));
            expect(await nft.mintPrice()).to.equal(ethers.utils.parseEther("0.2"));
        });
    
        it("Should not Allow Non-Owner of Power NFTA to Set the Mint Price", async function () {
            expect(await nft.mintPrice()).to.equal(ethers.utils.parseEther("0.1"));
            await expect(nft.connect(addr2).setMintPrice(ethers.utils.parseEther("0.2"))).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.mintPrice()).to.equal(ethers.utils.parseEther("0.1"));
        });
    
        it("Should Allow Owner of Power NFTA to Set the Bulk buy limit", async function () {
            expect(await nft.bulkBuyLimit()).to.equal(10);
            await nft.connect(addr1).setBulkBuyLimit(20);
            expect(await nft.bulkBuyLimit()).to.equal(20);
        });
    
        it("Should not Allow Non-Owner of Power NFTA to Set the Bulk buy limit", async function () {
            expect(await nft.bulkBuyLimit()).to.equal(10);
            await expect(nft.connect(addr2).setBulkBuyLimit(20)).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.bulkBuyLimit()).to.equal(10);
        });

        it("Should Allow Owner of Power NFTA to toggle paused", async function () {
            expect(await nft.isPaused()).to.equal(false);
            await nft.connect(addr1).togglePaused();
            expect(await nft.isPaused()).to.equal(true);
            await nft.connect(addr1).togglePaused();
            expect(await nft.isPaused()).to.equal(false);
        });
    
        it("Should not Allow Non-Owner of Power NFTA to toggle paused", async function () {
            expect(await nft.isPaused()).to.equal(false);
            await expect(nft.connect(addr2).togglePaused()).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.isPaused()).to.equal(false);
        });
    
        it("Should Allow Owner of Power NFTA to withdraw ETH", async function () {
            const balanceBefore = await ethers.provider.getBalance(addr1.address);
            const mintCost = await nft.mintPrice();
            expect(nft.address == deployedAddress, "NFT Address is not the same as the deployed address");
            await nft.connect(addr2).mintNFT(addr2.address, 1, { value: mintCost });
            expect(await nft.balanceOf(addr2.address)).to.equal(1);
            const balanceOfContract = await ethers.provider.getBalance(nft.address);
            expect(balanceOfContract).to.equal(mintCost);
            // Withdraw ETH
            const tx = await nft.connect(addr1).withdrawETH();
            //get gas cost of tx
            const gasCost = await tx.wait().then((receipt: any) => {
                return receipt.gasUsed.mul(tx.gasPrice);
            });
            const balanceAfter = await ethers.provider.getBalance(addr1.address);
            expect(balanceAfter > balanceBefore, "Balance after is not less than balance before");
            expect(balanceAfter).to.equal(balanceBefore.add(mintCost).sub(gasCost));
            const balanceOfContractAfter = await ethers.provider.getBalance(nft.address);
            expect(balanceOfContractAfter).to.equal(0);
        });
        
        it("Should not Allow Non-Owner of Power NFTA to withdraw ETH", async function () {
            const balanceBefore = await ethers.provider.getBalance(addr1.address);
            const mintCost = await nft.mintPrice();
            expect(nft.address == deployedAddress, "NFT Address is not the same as the deployed address");
            await nft.connect(addr2).mintNFT(addr2.address, 1, { value: mintCost });
            expect(await nft.balanceOf(addr2.address)).to.equal(1);
            const balanceOfContract = await ethers.provider.getBalance(nft.address);
            expect(balanceOfContract).to.equal(mintCost);
            // Withdraw ETH
            await expect(nft.connect(addr2).withdrawETH()).to.be.revertedWith("Ownable: caller is not the owner");
            const balanceAfter = await ethers.provider.getBalance(addr1.address);
            expect(balanceAfter).to.equal(balanceBefore);
            const balanceOfContractAfter = await ethers.provider.getBalance(nft.address);
            expect(balanceOfContractAfter).to.equal(mintCost);
        });
    
        it("Should Allow Owner of Power NFTA to withdraw ERC20", async function () {
            /// send DAI to contract
            const startingDAiBalance = await DAI.balanceOf(addr1.address);
            await DAI.connect(addr2).transfer(nft.address, ethers.utils.parseEther("100"));
            expect(await DAI.balanceOf(nft.address)).to.equal(ethers.utils.parseEther("100"));
    
            // Withdraw DAI
            await nft.connect(addr1).withdrawERC20(DAI.address);
            expect(await DAI.balanceOf(nft.address)).to.equal(0);
            expect(await DAI.balanceOf(addr1.address)).to.equal(startingDAiBalance.add(ethers.utils.parseEther("100")));
        
        });
    
        it("Should not Allow Non-Owner of Power NFTA to withdraw ERC20", async function () {
            /// send DAI to contract
            const startingDAiBalance = await DAI.balanceOf(addr1.address);
            await DAI.connect(addr2).transfer(nft.address, ethers.utils.parseEther("100"));
            expect(await DAI.balanceOf(nft.address)).to.equal(ethers.utils.parseEther("100"));
    
            // Withdraw DAI
            await expect(nft.connect(addr2).withdrawERC20(DAI.address)).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await DAI.balanceOf(nft.address)).to.equal(ethers.utils.parseEther("100"));
            expect(await DAI.balanceOf(addr1.address)).to.equal(startingDAiBalance);
        });
    
        it("Should Allow Owner of Power NFTA to reserve tokens", async function () {
            await nft.connect(addr1).reserveTokens(5)
            expect(await nft.balanceOf(addr1.address)).to.equal(5);
            expect(await nft.totalSupply()).to.equal(5);
        });
    
        it("Should not Allow Non-Owner of Power NFTA to reserve tokens", async function () {
            await expect(nft.connect(addr2).reserveTokens(5)).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await nft.balanceOf(addr1.address)).to.equal(0);
            expect(await nft.totalSupply()).to.equal(0);
        });
    
        it("Should allow owner to set new Default Royalties", async function () {
            const defaultRoyalties = await nft.royaltyInfo(1, ethers.utils.parseEther("1"));
            expect(defaultRoyalties[0]).to.equal(addr1.address);
            expect(defaultRoyalties[1]).to.equal(ethers.utils.parseEther("0.025"));

            await nft.connect(addr1).setRoyalties(addr2.address, 1000);
            const newDefaultRoyalties = await nft.royaltyInfo(1, ethers.utils.parseEther("1"));
            expect(newDefaultRoyalties[0]).to.equal(addr2.address);
            expect(newDefaultRoyalties[1]).to.equal(ethers.utils.parseEther("0.1"));
        });

        it("Should not allow non-owner to set new Default Royalties", async function () {
            const defaultRoyalties = await nft.royaltyInfo(1, ethers.utils.parseEther("1"));
            expect(defaultRoyalties[0]).to.equal(addr1.address);
            expect(defaultRoyalties[1]).to.equal(ethers.utils.parseEther("0.025"));

            await expect(nft.connect(addr2).setRoyalties(addr2.address, 1000)).to.be.revertedWith("Ownable: caller is not the owner");
            const newDefaultRoyalties = await nft.royaltyInfo(1, ethers.utils.parseEther("1"));
            expect(newDefaultRoyalties[0]).to.equal(addr1.address);
            expect(newDefaultRoyalties[1]).to.equal(ethers.utils.parseEther("0.025"));
        });

        it("Should support Interface 0x80ac58cd", async function () {
            expect(await nft.supportsInterface("0x80ac58cd")).to.equal(true);
            expect(await nft.supportsInterface("0x2a55205a")).to.equal(true);
            expect(await nft.supportsInterface("0x01ffc9a7")).to.equal(true);
            expect(await nft.supportsInterface("0x36372b07")).to.equal(false);
        });

        it("Should Return the correct Token URI", async function () {
            await nft.connect(addr1).reserveTokens(1)
            expect(await nft.tokenURI(1)).to.equal("https://test.io/nft/1.json");
        });

        it("Should return the correct type of NFT", async function () {
            expect(await nft.typeOf()).to.equal("dAgora PowerNFT");
        });

        it("Should not allow non Owner to toggle paused on the factory contract", async function () {
            await expect(factoryProxy.connect(addr2).togglePaused()).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await factoryProxy.isPaused()).to.equal(false);
        });

        it("Should allow owner to set min tier to create contract", async function (){
            expect(await factoryProxy.minPowerNFTATier()).to.equal(1);
            await factoryProxy.connect(dagoraTreasury).setMinPowerNFTATier(2);
            expect(await factoryProxy.minPowerNFTATier()).to.equal(2);
        }); 
    
        it("Should not allow non-Owner to set min tier to create contract", async function (){
            expect(await factoryProxy.minPowerNFTATier()).to.equal(1);
            await expect(factoryProxy.connect(addr2).setMinPowerNFTATier(2)).to.be.revertedWith("Ownable: caller is not the owner");
            expect(await factoryProxy.minPowerNFTATier()).to.equal(1);
        });

        it("Should revert mint function if contract is paused", async function () {
            await nft.connect(addr1).togglePaused();
            await expect(nft.connect(addr1).mintNFT(addr1.address, 1)).to.be.revertedWith("PowerNFT: contract is paused");
        });

        it("Should enforce max supply", async function () {
            for(let i = 0; i < 10; i++){
                await nft.connect(addr1).reserveTokens(10)
            }

            expect(await nft.totalSupply()).to.equal(100);
            await expect(nft.connect(addr1).reserveTokens(1)).to.be.revertedWith("PowerNFT: exceeds max supply");
            await expect(nft.connect(addr1).mintNFT(addr1.address, 1)).to.be.revertedWith("PowerNFT: exceeds max supply");
        });

        it("Should revert if insufficient funds are sent to mint", async function () {
            await expect(nft.connect(addr1).mintNFT(addr1.address, 1)).to.be.revertedWith("PowerNFT: insufficient funds");
        });

        it("Should revert TokenURI if token does not exist", async function () {
            await nft.connect(addr1).togglePaused();
            await expect(nft.tokenURI(1)).to.be.revertedWith("PowerNFT: URI query for nonexistent token");
        });

        it("Should revert if there are noo erc20 tokens to withdraw", async function () {
            await expect(nft.connect(addr1).withdrawERC20(DAI.address)).to.be.revertedWith("PowerNFT: no tokens to withdraw");
        });

        

});