# @version ^0.2.0

# Simple goFund me contract, that allows individual users to pool money for project

struct Project:
    name: String[30]
    fundsNeeded: uint256
    fullyFunded: bool

projectIdCounter: uint256

projectHash: HashMap[uint256, Project]

# Project ID -> Amount Funded
projectFunding: HashMap[uint256, uint256]

admin: address

@external
def __init__():
    self.admin = msg.sender
    self.projectIdCounter = 0

@external
def createProject(_name: String[30], _amount: uint256):
    newProject: Project = Project({
        name: _name,
        fundsNeeded: _amount,
        fullyFunded: False
    })
    self.projectHash[self.projectIdCounter] = newProject
    self.projectIdCounter += 1

@external
def fundProject(_id: uint256):
    assert self.projectHash[_id] != empty(Project)
    