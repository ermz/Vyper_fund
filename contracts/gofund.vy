# @version ^0.2.0

# Simple goFund me contract, that allows individual users to pool money for project

admin: address

@external
def __init__():
    self.admin = msg.sender