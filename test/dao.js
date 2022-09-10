const { expect } = require('chai');

describe('DAO Contract', () => {
	let DAO, roulette, TOKEN, owner, addr1, addr2;

	beforeEach(async () => {
		[owner, addr1, addr2, _] = await ethers.getSigners()
		let TOKEN_CONTRACT = await ethers.getContractFactory("MyToken");
		TOKEN = await TOKEN_CONTRACT.deploy()
		let DAO_CONTRACT = await ethers.getContractFactory("TheOpenFarmDAO");
		DAO = await DAO_CONTRACT.deploy(TOKEN.address)
		// const FoodToken = await ethers.getContractFactory("FOOD")
		// food = await FoodToken.deploy()
		// const PetToken = await ethers.getContractFactory("OpenPet")
		// pet = await PetToken.deploy()

		// Roulette = await ethers.getContractFactory("PetRoulette")
		// // roulette = await Roulette.deploy(treat.address, food.address, pet.address, 32);
		// roulette = await Roulette.deploy();
		// Roulette2 = await ethers.getContractFactory("Roulette")
		// roulette2 = await Roulette2.deploy(treat.address, 32);

		// [owner, addr1, addr2, _] = await ethers.getSigners()

			// await pet.connect(owner).setOwner(pet.address);
			// let petMasterAddress = await pet.connect(owner).masterAddress();
			// await roulette.connect(owner).setFaucetDripAmount(0);
			// await pet.connect(owner).setOwner(roulette.address);
			// await pet.connect(owner).setApprovalForAll(roulette.address, true);
			// await pet.connect(addr1).setApprovalForAll(roulette.address, true);
			
		let lastNumbers = []
		let userNumbers = []
	});
	// let fundBoth = () => 
	// 	new Promise(async (resolve, reject) => {
	// 		await food.connect(owner).approve(roulette.address, ethers.constants.MaxUint256.toString(10));
	// 		await treat.connect(owner).approve(roulette.address, ethers.constants.MaxUint256.toString(10));
	// 		await roulette.connect(owner).increaseFunds(ethers.utils.parseEther				("1000000000"));
	// 		await treat.connect(owner).transfer(addr1.address, ethers.utils.parseEther		("10000000"));

	// 		await treat.connect(addr1).approve(roulette.address, ethers.constants.MaxUint256.toString(10));
	// 		await roulette.connect(addr1).increaseFunds(ethers.utils.parseEther				("100000"));
	// 		resolve()
	// 	})
	describe('Deployment', () => {
		it('Should get the right owner', async () => {
			console.log("owner.address", owner.address)
			console.log("token.address", TOKEN.address)
			console.log("dao.address", DAO.address)
			expect(await DAO.owner()).to.equal(owner.address)
		})
		it('Should have minted a token', async () => {
			// await TOKEN.connect(owner).mint();
			// await TOKEN.connect(owner).mint(addr1.address,ethers.utils.parseEther("999"));
			let totalSupply = await TOKEN.totalSupply();
			console.log("totalSupply",ethers.utils.formatEther(totalSupply),totalSupply.toString())
			expect(totalSupply).to.equal(ethers.utils.parseEther("1000"))

			// await DAO.connect(owner).createProposal(1000, 5);
			// expect(await DAO.numProposals()).to.equal(1)
		})
		it('Should have signed up to DAO', async () => {
			await TOKEN.connect(owner).approve(DAO.address, ethers.constants.Two);
		})
		it('Should have all balance', async () => {
			let balanceOfOwner = await TOKEN.balanceOf(owner.address);
			expect(balanceOfOwner).to.equal(ethers.utils.parseEther("1000"))
		})
		// it('Should have one proposal', async () => {
		// 	console.log("DAO", DAO.address)
		// 	await DAO.connect(owner).createProposal(1000, 5);
		// 	console.log("proposal created!")
		// 	let numProposals = await DAO.numProposals()
		// 	console.log("numProposals", numProposals.toString())
		// 	expect(numProposals).to.equal(1)
		// })

		// it('Master shouldnt have requested game', async () => {
		// 	expect(await roulette.hasRequestedGame(owner.address)).to.equal(false)
		// })

		// it('Master shouldnt have any funds', async () => {
		// 	expect(await roulette.registeredFunds(owner.address)).to.equal(0)
		// })

		// it('Master should have total supply as balance', async () => {
		// 	const ownerBalance = await treat.balanceOf(owner.address);
		// 	expect(await treat.totalSupply()).to.equal(ownerBalance);
		// })

		// it('Should have funds (owner)', async () => {
		// 	await treat.connect(owner).approve(roulette.address, ethers.constants.Two);
		// 	await roulette.connect(owner).increaseFunds(ethers.constants.Two);
		// 	expect(await roulette.registeredFunds(owner.address)).to.equal(ethers.constants.Two);
		// })

		// it('Should have funds (player)', async () => {
		// 	await treat.connect(owner).transfer(addr1.address, ethers.constants.Two);
		// 	await treat.connect(addr1).approve(roulette.address, ethers.constants.One);
		// 	await roulette.connect(addr1).increaseFunds(ethers.constants.One);
		// 	expect(await roulette.registeredFunds(addr1.address)).to.equal(ethers.constants.One);
		// })

		// it('Should have placed 2 bets lose then win', async () => {
		// 	await fundBoth()

		// 	let gameRound;
		// 	let isResultRed;
		// 	let balance;
		// 	let balanceMaster;

		// 	let CONSTANT_MASTER_RANDOM = 0x2a
		// 	let CONSTANT_USER_RANDOM = 9991

		// 	await roulette.connect(owner).setInitHash(ethers.utils.solidityKeccak256([ "uint256" ], [ 0x2a ]), addr1.address); // 42 (?)

		// 	console.log("\n place bet 1 \n")
		// 	await roulette.connect(addr1).placeBet(5, 9991, ethers.utils.parseEther("100"));

		// 	let resultTx = await roulette.resolveBet(0x2a, ethers.utils.solidityKeccak256([ "uint256" ], [ 0x2a ]), addr1.address);
		// 	lastNumbers = await roulette.lastUserNumbers(addr1.address); console.log(" lastNumbers: "); console.log(( lastNumbers.map((amount) => ethers.utils.formatEther(amount)) ))

		// 	gameRound = await roulette.gameRounds(addr1.address);
		// 	balance = await roulette.registeredFunds(addr1.address);
		// 	balanceMaster = await roulette.registeredFunds(owner.address);
		// 	console.log(" result: "+( gameRound .lastResult ))
		// 	console.log(" funds: "+ethers.utils.formatEther( balance ))
		// 	console.log(" funds master: "+ethers.utils.formatEther( balanceMaster ))
		// 	console.log(" balance change: (-100)")


		// 	console.log("\n place bet 2 \n")
		// 	/*RESET*/await roulette.connect(owner).setInitHash(ethers.utils.solidityKeccak256([ "uint256" ], [ 0x2a ]), addr1.address); // 42 (?)
		// 	await roulette.connect(addr1).placeBet(1, 9991, ethers.utils.parseEther("100"));
		// 	await roulette.connect(addr1).placeBet(5, 9991, ethers.utils.parseEther("100"));
		// 	await roulette.connect(addr1).placeBet(10, 9991, ethers.utils.parseEther("100"));
		// 	await roulette.connect(addr1).placeBet(35, 9991, ethers.utils.parseEther("100"));

		// 	console.log(" resolving bet????????? : "+( gameRound .lastResult ))
		// 	resultTx = await roulette.resolveBet(0x2a, ethers.utils.solidityKeccak256([ "uint256" ], [ 0x2a ]), addr1.address);
		// 	lastNumbers = await roulette.lastUserNumbers(addr1.address); console.log(" lastNumbers: "); console.log(( lastNumbers.map((amount) => ethers.utils.formatEther(amount)) ))

		// 	gameRound = await roulette.gameRounds(addr1.address);
		// 	balance = await roulette.registeredFunds(addr1.address);
		// 	balanceMaster = await roulette.registeredFunds(owner.address);
		// 	console.log(" result: "+( gameRound .lastResult ))
		// 	console.log(" funds: "+ethers.utils.formatEther( balance ))
		// 	console.log(" funds master: "+ethers.utils.formatEther( balanceMaster ))

		// 	console.log(" trying to redeem this ",gameRound.petTokenId == 0)
		// 	console.log(" trying to redeem this ",ethers.utils.formatEther(gameRound.petTokenId,0))
		// 	await roulette.connect(addr1).redeemPrize(gameRound.petTokenId);
		// 	console.log(" prize redemeed ")
		// 	balance = await roulette.registeredFunds(addr1.address);
		// 	balanceMaster = await roulette.registeredFunds(owner.address);
		// 	console.log(" funds: "+ethers.utils.formatEther( balance ))
		// 	console.log(" funds master: "+ethers.utils.formatEther( balanceMaster ))
		// })
		// it('Should have bet in number twice', async () => {
		// 	await fundBoth()

		// 	let gameRound;
		// 	let isResultRed;
		// 	let balance;
		// 	let balanceMaster;

		// 	let CONSTANT_MASTER_RANDOM = 0x2a
		// 	let CONSTANT_USER_RANDOM = 9991

		// 	await roulette.connect(owner).setInitHash(ethers.utils.solidityKeccak256([ "uint256" ], [ 0x2a ]), addr1.address); // 42 (?)

		// 	console.log("\n place bet 1 \n")
		// 	await roulette.connect(addr1).placeBet(9, 9991, ethers.utils.parseEther("100"));
		// 	// await roulette.connect(addr1).placeBet(9, 9991, ethers.utils.parseEther("100"));
		// 	await roulette.connect(addr1).betBulk(0, 9991, ethers.utils.parseEther("10"));
		// 	userNumbers = await roulette.userNumbers(addr1.address); console.log(" userNumbers: "); console.log( userNumbers.map((amount) => ethers.utils.formatEther(amount)) )

		// 	let resultTx = await roulette.resolveBet(0x2a, ethers.utils.solidityKeccak256([ "uint256" ], [ 0x2a ]), addr1.address);
		// 	lastNumbers = await roulette.lastUserNumbers(addr1.address); console.log(" lastNumbers: "); console.log(( lastNumbers.map((amount) => ethers.utils.formatEther(amount)) ))

		// 	gameRound = await roulette.gameRounds(addr1.address);
		// 	balance = await roulette.registeredFunds(addr1.address);
		// 	balanceMaster = await roulette.registeredFunds(owner.address);
		// 	console.log(" result: "+( gameRound .lastResult ))
		// 	console.log(" funds: "+ethers.utils.formatEther( balance ))
		// 	console.log(" funds master: "+ethers.utils.formatEther( balanceMaster ))
		// 	console.log(" balance change: (-100)")
		// 	console.log(" trying to redeem this ",gameRound.petTokenId == 0)
		// 	console.log(" trying to redeem this ",ethers.utils.formatEther(gameRound.petTokenId,1))
		// 	await roulette.connect(addr1).redeemSpecialPrize(gameRound.petTokenId);
		// 	console.log(" prize redemeed ")
		// 	balance = await roulette.registeredFunds(addr1.address);
		// 	balanceMaster = await roulette.registeredFunds(owner.address);
		// 	console.log(" funds: "+ethers.utils.formatEther( balance ))
		// 	console.log(" funds master: "+ethers.utils.formatEther( balanceMaster ))
		// })

		// it('Should have placed 2 multi bets win/lose', async () => {
		// 	await treat.connect(owner).approve(roulette.address, ethers.utils.parseEther	("10000000"));
		// 	await roulette.connect(owner).increaseFunds(ethers.utils.parseEther				("10000000"));
		// 	await treat.connect(owner).transfer(addr1.address, ethers.utils.parseEther		("10000000"));

		// 	await treat.connect(addr1).approve(roulette.address, ethers.utils.parseEther	("1000000"));
		// 	await roulette.connect(addr1).increaseFunds(ethers.utils.parseEther				("1000000"));
			
		// 	console.log("\n place multi bet (red) win \n")
		// 	/*RESET*/await roulette.connect(owner).setInitHash(ethers.utils.solidityKeccak256([ "uint256" ], [ 0x2a ]), addr1.address); // 42 (?)

		// 	await roulette.connect(addr1).betBulk(0, 9992, ethers.utils.parseEther("100"));
		// 	userNumbers = await roulette.userNumbers(addr1.address); console.log(" userNumbers: "); console.log( userNumbers.map((amount) => ethers.utils.formatEther(amount)) )
		// 	resultTx = await roulette.resolveBet(0x2a, ethers.utils.solidityKeccak256([ "uint256" ], [ 0x2a ]), addr1.address);
		// 	lastNumbers = await roulette.lastUserNumbers(addr1.address); console.log(" lastNumbers: "); console.log(( lastNumbers.map((amount) => ethers.utils.formatEther(amount)) ))

		// 	gameRound = await roulette.gameRounds(addr1.address);
		// 	balance = await roulette.registeredFunds(addr1.address);
		// 	console.log(" result: "+( gameRound .lastResult ))
		// 	console.log(" funds: "+ethers.utils.formatEther( balance ))



		// 	console.log("\n place multi bet constant (black) lose \n")
		// 	/*RESET*/await roulette.connect(owner).setInitHash(ethers.utils.solidityKeccak256([ "uint256" ], [ 0x2a ]), addr1.address); // 42 (?)

		// 	await roulette.connect(addr1).betBulk(1, 9992, ethers.utils.parseEther("100"));
		// 	resultTx = await roulette.resolveBet(0x2a, ethers.utils.solidityKeccak256([ "uint256" ], [ 0x2a ]), addr1.address);
		// 	lastNumbers = await roulette.lastUserNumbers(addr1.address); console.log(" lastNumbers: "); console.log(( lastNumbers.map((amount) => ethers.utils.formatEther(amount)) ))

		// 	gameRound = await roulette.gameRounds(addr1.address);
		// 	balance = await roulette.registeredFunds(addr1.address);
		// 	console.log(" result: "+( gameRound .lastResult ))
		// 	console.log(" funds: "+ethers.utils.formatEther( balance ))
		// })

		// it('Should have remove a number in bet then bet multi then lose', async () => {
		// 	await fundBoth()
		// 	await roulette.connect(owner).setInitHash(ethers.utils.solidityKeccak256([ "uint256" ], [ 0x2a ]), addr1.address); // 42 (?)

		// 	let CONSTANT_RANDOM = 1+parseInt(Math.random() * 100)

		// 	console.log("\n place bet 1 \n")
		// 	await roulette.connect(addr1).placeBet(3, (CONSTANT_RANDOM), ethers.utils.parseEther("100"));
		// 	await roulette.connect(addr1).placeBet(5, (CONSTANT_RANDOM), ethers.utils.parseEther("100"));
		// 	await roulette.connect(addr1).placeBet(9, (CONSTANT_RANDOM), ethers.utils.parseEther("100"));

		// 	let preGameRound = await roulette.gameRounds(addr1.address);
		// 	console.log("userRandom: "+(preGameRound.userRandom))
		// 	let lockedFunds;
		// 	userNumbers = await roulette.userNumbers(addr1.address); console.log(" userNumbers: "); console.log(( userNumbers.map((amount) => ethers.utils.formatEther(amount)) ))
		// 	lockedFunds = await roulette.gameRounds(addr1.address); console.log(" lockedFunds: "+ethers.utils.formatEther( lockedFunds.lockedFunds ))
		// 	await roulette.connect(addr1).removeBet(9);
		// 	userNumbers = await roulette.userNumbers(addr1.address); console.log(" userNumbers: "); console.log(( userNumbers.map((amount) => ethers.utils.formatEther(amount)) ))
		// 	lockedFunds = await roulette.gameRounds(addr1.address); console.log(" lockedFunds: "+ethers.utils.formatEther( lockedFunds.lockedFunds ))

		// 	await roulette.connect(addr1).betBulk(0, CONSTANT_RANDOM, ethers.utils.parseEther("100"));

		// 	let resultTx = await roulette.resolveBet(0x2a, ethers.utils.solidityKeccak256([ "uint256" ], [ 0x2a ]), addr1.address);
		// 	lastNumbers = await roulette.lastUserNumbers(addr1.address); console.log(" lastNumbers: "); console.log(( lastNumbers.map((amount) => ethers.utils.formatEther(amount)) ))

		// 	let gameRound = await roulette.gameRounds(addr1.address);
		// 	let balance = await roulette.registeredFunds(addr1.address);
		// 	console.log(" result: "+( gameRound .lastResult ))
		// 	console.log(" funds: "+ethers.utils.formatEther( balance ))
		// })

		// it('Should have remove a big number in bet then bet multi then win', async () => {
		// 	await fundBoth()
		// 	let balance
		// 	let balanceMaster
		// 	await roulette.connect(owner).setInitHash(ethers.utils.solidityKeccak256([ "uint256" ], [ 0x2a ]), addr1.address); // 42 (?)

		// 	console.log("\n place bet 1 \n")
		// 	balance = await roulette.registeredFunds(addr1.address);
		// 	balanceMaster = await roulette.registeredFunds(owner.address);
		// 	console.log(" funds: "+ethers.utils.formatEther( balance ))
		// 	console.log(" funds master: "+ethers.utils.formatEther( balanceMaster ))

		// 	await roulette.connect(addr1).placeBet(3, (9991), ethers.utils.parseEther("10"));
		// 	await roulette.connect(addr1).placeBet(5, (9991), ethers.utils.parseEther("1000"));
		// 	await roulette.connect(addr1).placeBet(6, (9991), ethers.utils.parseEther("10"));

		// 	let preGameRound = await roulette.gameRounds(addr1.address);
		// 	console.log("userRandom: "+(preGameRound.userRandom))
		// 	let lockedFunds;
		// 	userNumbers = await roulette.userNumbers(addr1.address); console.log(" userNumbers: "); console.log(( userNumbers.map((amount) => ethers.utils.formatEther(amount)) ))
		// 	lockedFunds = await roulette.gameRounds(addr1.address); console.log(" lockedFunds: "+ethers.utils.formatEther( lockedFunds.lockedFunds ))
		// 	lockedFunds = await roulette.gameRounds(addr1.address); console.log(" lockedFunds master: "+ethers.utils.formatEther( lockedFunds.masterLockedFunds ))
		// 	await roulette.connect(addr1).removeBet(5);
		// 	userNumbers = await roulette.userNumbers(addr1.address); console.log(" userNumbers: "); console.log(( userNumbers.map((amount) => ethers.utils.formatEther(amount)) ))
		// 	lockedFunds = await roulette.gameRounds(addr1.address); console.log(" lockedFunds: "+ethers.utils.formatEther( lockedFunds.lockedFunds ))
		// 	lockedFunds = await roulette.gameRounds(addr1.address); console.log(" lockedFunds master: "+ethers.utils.formatEther( lockedFunds.masterLockedFunds ))

		// 	await roulette.connect(addr1).betBulk(0, 9991, ethers.utils.parseEther("1"));

		// 	let resultTx = await roulette.resolveBet(0x2a, ethers.utils.solidityKeccak256([ "uint256" ], [ 0x2a ]), addr1.address);
		// 	lastNumbers = await roulette.lastUserNumbers(addr1.address); console.log(" lastNumbers: "); console.log(( lastNumbers.map((amount) => ethers.utils.formatEther(amount)) ))
		// 	lockedFunds = await roulette.gameRounds(addr1.address); console.log(" lockedFunds master: "+ethers.utils.formatEther( lockedFunds.masterLockedFunds ))

		// 	let gameRound = await roulette.gameRounds(addr1.address);
		// 	balance = await roulette.registeredFunds(addr1.address);
		// 	balanceMaster = await roulette.registeredFunds(owner.address);
			
		// 	console.log(" result: "+( gameRound .lastResult ))
		// 	console.log(" funds: "+ethers.utils.formatEther( balance ))
		// 	console.log(" funds master: "+ethers.utils.formatEther( balanceMaster ))
		// })


	})
})