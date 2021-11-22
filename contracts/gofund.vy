# @version ^0.2.0

# Simple goFund me contract, that allows individual users to pool money for project

struct Project:
    owner: address
    name: String[30]
    fundsNeeded: uint256
    fullyFunded: bool

projectIdCounter: uint256

projectHash: HashMap[uint256, Project]

# Project ID -> Amount Funded
projectFunding: HashMap[uint256, uint256]

# Project ID -> donor address -> amount donated
donoList: HashMap[uint256, HashMap[address, uint256]]

# Project ID -> address list
donoDonors: HashMap[uint256, address[100]]

# Project ID -> unique donor voter ID
# donoNumber only increases if there is a new "donor"
donoNumber: HashMap[uint256, uint256]

admin: address

@external
def __init__():
    self.admin = msg.sender
    self.projectIdCounter = 0

@external
def createProject(_name: String[30], _amount: uint256):
    newProject: Project = Project({
        owner: msg.sender,
        name: _name,
        fundsNeeded: _amount,
        fullyFunded: False
    })
    self.projectHash[self.projectIdCounter] = newProject
    self.donoNumber[self.projectIdCounter] = 0
    self.projectIdCounter += 1

@payable
@external
def fundProject(_id: uint256):
    assert self.projectHash[_id] != empty(Project)
    assert self.projectHash[_id].fullyFunded == False
    self.projectFunding[_id] += msg.value

    if self.donoList[_id][msg.sender] <= 0:
        self.donoDonors[_id][self.donoNumber[_id]] = msg.sender
        self.donoNumber[_id] += 1

    self.donoList[_id][msg.sender] += msg.value
    if self.projectFunding[_id] >= self.projectHash[_id].fundsNeeded:
        self.projectHash[_id].fullyFunded = True
    
@external
def endFund(_id: uint256):
    assert self.projectHash[_id].owner == msg.sender, "You are not the owner of this project"
    assert self.projectHash[_id].fullyFunded == True
    # Convert send amount to percentage and keep some, for use of service(profit)
    send(msg.sender, self.projectFunding[_id])

# Each contributor receives one token for every ether they contributed to the project 
# An additional incentive for donors
@external
def distributeToken(_id: uint256):
    assert self.projectHash[_id].owner == msg.sender, "You are not the owner of this project"
    assert self.projectHash[_id].fullyFunded == True
    