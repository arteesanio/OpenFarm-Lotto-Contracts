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
		it('Should create player with reference', async () => {
			let anOwner = await SIMULATION.connect(owner).createPlayer(SIMULATION.address,"owner")
			let aPlayerResult = await SIMULATION.connect(addr1).createPlayer(owner.address,"myname")

			let playerLegacy = await SIMULATION.connect(addr1).getMyLegacy()
			playerLegacy.map((item, index) => {
				console.table({
					"interest | memory #": index,
					cat: THOUGHT_CATEGORY_LIST[item.thoughtCat],
					birth: new Date(Date(item.birthunix.toString())).toLocaleDateString(),
				})	
			})
		})
		it('Should add energy and generate wish', async () => {
			let aPlayerResult = await SIMULATION.connect(addr2).createPlayer(SIMULATION.address,"player 2")
			let playerLegacy = await SIMULATION.connect(addr2).getMyLegacy()
			playerLegacy.map((item, index) => {
				console.log(THOUGHT_CATEGORY_LIST[item.thoughtCat])
			})


			let addEnergyTx = await SIMULATION.connect(addr2).addPlayerEnergy(18,8,8,8)
			let selectedPplayer = await SIMULATION.players(addr2.address)
			console.log(selectedPplayer.globalState)


			let aPlayerMainWish = await SIMULATION.connect(addr2).getMyMemory(3) // first wish ?
			console.log(
				"player 2 | main wish:", THOUGHT_CATEGORY_LIST[aPlayerMainWish.thoughtCat],
				"wish:", aPlayerMainWish.isStatusStateDependant,
			)
			console.log(aPlayerMainWish.birthunix.toString(),"\n\n\n")

			// should fail
			// await expect(SIMULATION.connect(addr2).addPlayerEnergy(8,8,8,8)).to.be.reverted
						// suppose the current block has a timestamp of 01:00 PM
			await network.provider.send("evm_increaseTime", [3600*16])
			await network.provider.send("evm_mine") // this one will have 02:00 PM as its timestamp
			console.log("*** advance time *** | (sinning energy) ")
			await SIMULATION.connect(addr2).addPlayerEnergy(248,123,48,128)

			let selectedPplayer2 = await SIMULATION.players(addr2.address)
			console.table({
				energy: selectedPplayer2.globalState.energy,
				fun: selectedPplayer2.globalState.fun,
				hygene: selectedPplayer2.globalState.hygene,
				protein: selectedPplayer2.globalState.protein,
			})
			console.log("selectedPplayer2.globalState.energy", selectedPplayer2.globalState.energy)



			let aPlayerRegularWish = await SIMULATION.connect(addr2).getMyMemory(4) // second wish ?
			console.log(
				"player 2 | regular wish:", THOUGHT_CATEGORY_LIST[aPlayerRegularWish.thoughtCat]
			)

		})

		it('Should fufill wish', async () => {
			let aPlayerResult = await SIMULATION.connect(addr2).createPlayer(SIMULATION.address,"player 2")
			let addEnergyTx = await SIMULATION.connect(addr2).addPlayerEnergy(208,208,208,208)
			{
				let aPlayerMainWish = await SIMULATION.connect(addr2).getMyMemory(3) // first wish ?
				console.log(
					"player 2 | wish:", THOUGHT_CATEGORY_LIST[aPlayerMainWish.thoughtCat],
					"\nisStatusStateDependant:", aPlayerMainWish.isStatusStateDependant,
					"\nisWish:", aPlayerMainWish.isWish,
				)
				// console.log(aPlayerMainWish.birthunix.toString(),"\n\n\n")
				let aPlayerFufillWish = await SIMULATION.connect(addr2).fufillWish(3) // first wish ?
			}

			{
				let aPlayerMainWish = await SIMULATION.connect(addr2).getMyMemory(3) // first wish ?
				console.log(
					"\n\n\nplayer 2 | wish:", THOUGHT_CATEGORY_LIST[aPlayerMainWish.thoughtCat],
					"\nisStatusStateDependant:", aPlayerMainWish.isStatusStateDependant,
					"\nisWish:", aPlayerMainWish.isWish,
				)
			}


		})


	})
})