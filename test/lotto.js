const { expect } = require('chai');

describe('LOTTO Contract', () => {
	let DAO, LOTTO, TOKEN, owner, addr1, addr2;

	beforeEach(async () => {
		[owner, addr1, addr2, _] = await ethers.getSigners()
		let TOKEN_CONTRACT = await ethers.getContractFactory("MyToken");
		TOKEN = await TOKEN_CONTRACT.deploy()
		console.log("token.address", TOKEN.address)
		let VRF_CONTRACT = await ethers.getContractFactory("FakeVRF");
		VRF = await VRF_CONTRACT.deploy()

		let LOTTO_CONTRACT = await ethers.getContractFactory("TheOpenFarmDAOsLotto");
		LOTTO = await LOTTO_CONTRACT.deploy(TOKEN.address, VRF.address)
		let DAO_CONTRACT = await ethers.getContractFactory("TheOpenFarmDAO");
		DAO = await DAO_CONTRACT.deploy(TOKEN.address,LOTTO.address)
	
		await LOTTO.connect(owner).transferOwnership(DAO.address);
		await TOKEN.connect(owner).approve(DAO.address, ethers.utils.parseEther("999"));
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
		it('Should have resolved a proposal', async () => {
			let voting = await DAO.connect(owner).voteOnProposal(0, 1000, owner.address); await voting.wait()
			await network.provider.send("evm_increaseTime", [3600])
			await network.provider.send("evm_mine") 
			let newRound = await DAO.connect(owner).executeProposal(0); await newRound.wait()

			let generation = await LOTTO.connect(owner).requestResolveRound(0); await generation.wait()

			let finish = await LOTTO.connect(owner).resolveBet(0); await finish.wait()
			// expect(numProposals).to.equal(1)
		})
	})
})
