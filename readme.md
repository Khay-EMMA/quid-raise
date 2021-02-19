# QuidRaise

QuidRaise is a transparent and decentralized crowdfunding protocol using the Binance Smart Chain

## Team Members

1. Njoku Emmanuel
    - kalunjoku123@gmail.com
    - Github Profile: https://github.com/Khay-EMMA 

2. Owanate Amachree 
    - amachreeowanate@gmail.com
    - Github Profile: https://github.com/owans


## Smart Contract Flow🥑🍕

- User(Admin) will start a Campaign or a Project for fundraising with a Specific Goal and Deadline💖

- Contributors will contribute to that project by sending the required Tokens(in this case BUSD).😋💵

- The User(Admin) will create a Spending Request every time he wants to use any amount from those funds😁

- The Contributors will vote for that Spending Request.😮

- If more than 50% of the total contributors vote for that request then the User(admin) will get permission to use the amount mentioned in the Spending Request🎉🔥

- The contributors can withdraw their BUSD if the required amount(Goal) was not raised within the Deadline

## Running Smart Contract with Truffle and ganache blockchain locally

```bash
# Clone Repo
$ git clone `https://github.com/Khay-EMMA/quid-raise.git`

# Install Dependencies
$ yarn install

```

## Connecting to Ganache and compiling contract

```bash
# Connect to ganache blockchain
$ ganache-cli -a

# Run Migration and deploy to local blockchain
$ truffle migrate

```
