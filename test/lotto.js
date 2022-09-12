const { expect } = require('chai');

describe('LOTTO Contract', () => {
	let DAO, LOTTO, TOKEN, owner, addr1, addr2;

	beforeEach(async () => {
		[owner, addr1, addr2, _] = await ethers.getSigners()
		console.log("addresses", owner.address, addr1.address, addr2.address, _.address,)
		let TOKEN_CONTRACT = await ethers.getContractFactory("MyToken");
		TOKEN = await TOKEN_CONTRACT.deploy()
		console.log("token.address", TOKEN.address)
		let VRF_CONTRACT = await ethers.getContractFactory("FakeVRF");
		VRF = await VRF_CONTRACT.deploy()

		let LOTTO_CONTRACT = await ethers.getContractFactory("TheOpenLotto");
		LOTTO = await LOTTO_CONTRACT.deploy(TOKEN.address, VRF.address)
		let DAO_CONTRACT = await ethers.getContractFactory("TheOpenLottoDAO");
		DAO = await DAO_CONTRACT.deploy(TOKEN.address,LOTTO.address)
	
		await LOTTO.connect(owner).transferOwnership(DAO.address);
		await TOKEN.connect(owner).approve(DAO.address, ethers.utils.parseEther("999"));
		await TOKEN.connect(addr1).approve(DAO.address, ethers.utils.parseEther("999"));
		let creation = await DAO.connect(owner).createProposal(1000, 5);
		await creation.wait()
	});
	describe('Deployment', () => {
		it('Should get the right owner', async () => {
			console.log("owner.address", owner.address)
			console.log("token.address", TOKEN.address)
			console.log("dao.address", DAO.address)
			expect(await LOTTO.owner()).to.equal(DAO.address)
		})
		it('Should have one voted', async () => {
			let voting = await DAO.connect(owner).voteOnProposal(0, 100, owner.address); await voting.wait()
		})
		it('Should have to wait', async () => {
			await expect(DAO.connect(owner).executeProposal(0)).to.be.revertedWith('DEADLINE_NOT_EXCEEDED');
		})
		it('Should have resolved a proposal', async () => {
			let balance1 = await TOKEN.balanceOf(owner.address);
			let balance2 = await TOKEN.connect(owner).transfer(addr1.address, ethers.utils.parseEther("300"));
			
			{
				let balancea = await TOKEN.balanceOf(owner.address); console.log("balancea", ethers.utils.formatEther(balancea))
				let balanceb = await TOKEN.balanceOf(addr1.address); console.log("balanceb", ethers.utils.formatEther(balanceb))
			}
			let voting = await DAO.connect(addr1).voteOnProposal(0, 250, owner.address); await voting.wait()
			let voting2 = await DAO.connect(owner).voteOnProposal(0, 1500, addr1.address); await voting2.wait()
			await network.provider.send("evm_increaseTime", [3600])
			await network.provider.send("evm_mine") 

			let balancetotalpre = await TOKEN.balanceOf(DAO.address); console.log("pre balance total", ethers.utils.formatEther(balancetotalpre))

			let newRound = await DAO.connect(owner).executeProposal(0); await newRound.wait()
			let generation = await LOTTO.connect(owner).requestResolveRound(0); await generation.wait()

			let finish = await LOTTO.connect(owner).resolveBet(0); await finish.wait()
			{
				let balancea = await TOKEN.balanceOf(owner.address); console.log("balancea", ethers.utils.formatEther(balancea))
				let balanceb = await TOKEN.balanceOf(addr1.address); console.log("balanceb", ethers.utils.formatEther(balanceb))
			}
			let total = 0
			for (var i = 2000 - 1; i >= 0; i--) {
				let oneResult = await LOTTO.connect(owner).getWonAmount(0,i); 
				if (oneResult == 0) continue
				console.log("oneResult",i,ethers.utils.formatEther(oneResult))
				total += parseFloat(ethers.utils.formatEther(oneResult))
			}
			console.log("total", total)
			{
				let withdraw = await LOTTO.connect(addr1).withdrawAll(0,0,addr1.address,250);
				console.log("withdraw")
				console.log(withdraw.value.toString())
				let withdrawRef = await DAO.connect(addr1).withdrawRefBonus(0);
			}
			{
				let withdraw = await LOTTO.connect(owner).withdrawAll(0,250,owner.address,1500);
				console.log("withdraw")
				console.log(withdraw.value.toString())
				let withdrawRef = await DAO.connect(owner).withdrawRefBonus(0);
			}
			{
				let balancea = await TOKEN.balanceOf(owner.address); console.log("balancea", ethers.utils.formatEther(balancea))
				let balanceb = await TOKEN.balanceOf(addr1.address); console.log("balanceb", ethers.utils.formatEther(balanceb))
			}
			let balancetotal = await TOKEN.balanceOf(DAO.address); console.log("dao balance total", ethers.utils.formatEther(balancetotal))
			let balancetotallotto = await TOKEN.balanceOf(LOTTO.address); console.log("lotto balance total", ethers.utils.formatEther(balancetotallotto))
			{
				let withdraw = await DAO.connect(owner).withdrawBalance();
				console.log("withdraw")
				console.log(withdraw.value.toString())
				let balancetotal2 = await TOKEN.balanceOf(DAO.address); console.log("2 dao balance total", ethers.utils.formatEther(balancetotal2))
			}

			{
				let balancea = await TOKEN.balanceOf(owner.address); console.log("balancea", ethers.utils.formatEther(balancea))
				let balanceb = await TOKEN.balanceOf(addr1.address); console.log("balanceb", ethers.utils.formatEther(balanceb))
			}
		})
	})
})
