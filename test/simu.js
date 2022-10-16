const { expect } = require('chai');

const THOUGHT_CATEGORY_LIST = ["supernatural", "ambition", "art", "hazards", "logic", "pets", "social", "sports"];

describe('Simulation Contract', () => {
	let SIMULATION, owner, addr1, addr2;

	beforeEach(async () => {
		[owner, addr1, addr2, _] = await ethers.getSigners()
		let SIMULATION_CONTRACT = await ethers.getContractFactory("TheOpenSimulation");
		SIMULATION = await SIMULATION_CONTRACT.deploy()
		console.log("\n", "simulation address", SIMULATION.address )
	});
	describe('Deployment', () => {
		it('Should have thoughts', async () => {
			// console.log("SIMULATION address", SIMULATION.address)
			let supernaturalThoughtItem = await SIMULATION.thoughts(0,0)
			// console.log("supernaturalThoughtItem", supernaturalThoughtItem)
			expect(supernaturalThoughtItem.id).to.equal(0)
		})
		it('Should create player', async () => {
			let anOwner = await SIMULATION.connect(owner).createPlayer(SIMULATION.address,"owner")
			let ownerPlayerMemory = await SIMULATION.connect(owner).getMyMemory(0)
			console.log(
				"player 0 | main interest:", THOUGHT_CATEGORY_LIST [ownerPlayerMemory.thoughtCat]
			)
			console.log(ownerPlayerMemory.birthunix.toString(),"\n\n\n")
		})
		it('Should create player with and without ref', async () => {
			let anOwner = await SIMULATION.connect(owner).createPlayer(SIMULATION.address,"owner")
			let aPlayerResult = await SIMULATION.connect(addr1).createPlayer(owner.address,"myname")

			let playerLegacy = await SIMULATION.connect(addr1).getMyLegacy()
			playerLegacy.map((item, index) => {
				console.table({
					"memory#": index,
					cat: THOUGHT_CATEGORY_LIST[item.thoughtCat],
					birth: item.birthunix.toString(),
				})	
			})
		})
		it('Should add stat:energy', async () => {
			let aPlayerResult = await SIMULATION.connect(addr2).createPlayer(SIMULATION.address,"player 2")
			let playerLegacy = await SIMULATION.connect(addr2).getMyLegacy()
			playerLegacy.map((item, index) => {
				console.log(THOUGHT_CATEGORY_LIST[item.thoughtCat])
			})


			let addEnergyTx = await SIMULATION.connect(addr2).addPlayerEnergy(8)
			let selectedPplayer = await SIMULATION.players(addr2.address)
			console.log(selectedPplayer.status)


			let aPlayerWish = await SIMULATION.connect(addr2).getMyMemory(3) // first wish ?
			console.log(
				"player 2 | main wish:", THOUGHT_CATEGORY_LIST[aPlayerWish.thoughtCat]
			)
			console.log(aPlayerWish.birthunix.toString(),"\n\n\n")

			// should fail
			await expect(SIMULATION.connect(addr2).addPlayerEnergy(8)).to.be.reverted
		})
	})
})