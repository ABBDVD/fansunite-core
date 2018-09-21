/* global assert, contract, it, before, after, afterEach, artifacts, describe */

let Vault = artifacts.require('./Vault');
let Registry = artifacts.require('./Registry');
let Token = artifacts.require('./test/mocks/Token.sol');
const { ensureException } = require('./helpers/utils');
const { NULL_ADDRESS } = require('./helpers/constants');
const ETH_TOKEN_ADDRESS = NULL_ADDRESS;

contract('Vault', async accounts => {

  let owner = accounts[0];
  let instance;
  let dummyAddressA = "0x1111111111111111111111111111111111111111";

  before('setup contract instance', async () => {
    instance = await Vault.deployed();
  });

  describe('Test cases for depositing ETH', async () => {

    describe('Test cases for valid ETH deposit', async () => {

      it('should successfully deposit ETH into the vault', async () => {
        const depositAmount = 2;
        await instance.deposit(ETH_TOKEN_ADDRESS, 0, { from: owner, value: depositAmount});
        const vaultBalance = await instance.balanceOf.call(ETH_TOKEN_ADDRESS, owner);

        assert.equal(vaultBalance, depositAmount, 'invalid vault balance');
      });

    });

    describe('Test cases for invalid ETH deposit', async () => {

      it('should revert if msg.value is zero', async () => {
        try {
          await instance.deposit(ETH_TOKEN_ADDRESS, 0, { from: accounts[1], value: 0 });
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if amount does not equal 0', async () => {
        try {
          await instance.deposit(ETH_TOKEN_ADDRESS, 1, { from: accounts[1], value: 1 });
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

    });

  });


  describe('Test cases for depositing ERC20 tokens', async () => {
    let token;
    const mintAmount = 1000;

    before('deploy mock ERC20 token and mint tokesn', async () => {
      token = await Token.new();
      await token.mint(accounts[1], mintAmount);
    });

    describe('Test cases for valid ERC20 token deposit', async () => {

      it('should successfully deposit ERC20 tokens into the vault', async () => {
        const depositAmount = mintAmount / 2 ;
        await instance.deposit(token.address, depositAmount, {from: accounts[1]});
        const vaultBalance = await instance.balanceOf.call(token.address, accounts[1]);
        const tokenBalance = await token.balanceOf.call(accounts[1]);

        assert.equal(vaultBalance, depositAmount, 'invalid token balance amount in vault');
        assert.equal(tokenBalance, mintAmount - depositAmount, 'invalid token balance amount');
      });

    });

    describe('Test cases for invalid ERC20 token deposit', async () => {

      it('should revert if the deposit amount sent is 0', async () => {
        try {
          await instance.deposit(token.address, 0, {from: accounts[1]});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if msg.value is greater than 0', async () => {
        try {
          await instance.deposit(token.address, 100, {from: accounts[1], value: 1});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

    });

  });

  describe('Test cases for withdrawing ETH', async () => {
    let vaultBalanceBefore;

    beforeEach('deposit ETH into vault', async() => {
      await instance.deposit(ETH_TOKEN_ADDRESS, 0, {from: accounts[1], value: 2});
      vaultBalanceBefore = await instance.balanceOf(ETH_TOKEN_ADDRESS, accounts[1]);
    });

    describe('Test cases for valid ETH withdrawals', async () => {

      it('should successfully withdraw ETH from the vault', async () => {
        await instance.withdraw(ETH_TOKEN_ADDRESS, 2, {from: accounts[1]});
        const vaultBalance = await instance.balanceOf(ETH_TOKEN_ADDRESS, accounts[1]);

        assert.equal(vaultBalance, vaultBalanceBefore - 2, 'invalid ETH vault balance');
      });

    });

    describe('Test cases for invalid ETH withdrawal', async() => {

      it('should revert if amount is not greater than 0', async () => {
        try {
          await instance.withdraw(ETH_TOKEN_ADDRESS, 0, {from: accounts[1]});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if attempting to withdrawal amount exceeds balance within the vault', async () => {
        const vaultBalance = await instance.balanceOf(ETH_TOKEN_ADDRESS, accounts[1]);
        try {
          await instance.withdraw(ETH_TOKEN_ADDRESS, vaultBalance + 1, {from: accounts[1]});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

    });

  });

  describe('Test cases for withdrawing ERC20 tokens', async () => {

    let token;
    let vaultBalanceBefore;
    const mintAmount = 1000;
    const depositAmount = mintAmount / 2 ;

    before('deploy mock ERC20 token', async () => {
      token = await Token.new();
      await token.mint(accounts[1], mintAmount);
      await instance.deposit(token.address, depositAmount, {from: accounts[1]});
      vaultBalanceBefore = await instance.balanceOf(token.address, accounts[1]);
    });

    describe('Test cases for invalid ERC20 token withdrawals', async () => {

      it('should successfully withdraw the ERC20 tokens from the vault', async () => {
        await instance.withdraw(token.address, depositAmount, {from: accounts[1]});
        const vaultBalance = await instance.balanceOf(token.address, accounts[1]);

        assert.equal(vaultBalance, vaultBalanceBefore - depositAmount, 'invalid ERC20 vault balance');
      });

    });

    describe('Test cases for valid ERC20 token withdrawals', async () => {

      it('should revert if amount is not greater than 0', async () => {
        try {
          await instance.withdraw(token.address, 0, { from: accounts[1] });
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if attempting to withdraw more than vault balance', async () => {
        try {
          await instance.withdraw(token.address, vaultBalanceBefore + 1, { from: accounts[1] });
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

    });

  });

  describe('Test cases for approving spenders', async () => {

    let spenderAddress;

    before('get registered bet manager address', async () => {
      const registry = await Registry.deployed();
      await registry.changeAddress('BetManager', dummyAddressA);
      spenderAddress = await registry.getAddress.call('BetManager');
      await instance.addSpender(spenderAddress, {from:owner});
    });

    it('should successfully approve a valid spender', async () => {
      instance.approve(spenderAddress, {from: accounts[1]});
      const isApproved = await instance.isApproved.call(accounts[1], spenderAddress);

      assert.isTrue(isApproved, 'spender was not approved');
    });

    it('should revert if the spender is not registered', async () => {
      try {
        await instance.approve(NULL_ADDRESS, {from: accounts[1]});
      } catch (err) {
        ensureException(err);
        return;
      }

      assert.fail('Expected throw not received');
    });

  });

  describe('Test cases for adding a spender', async () => {

    let betManagerAddress;

    before('get registered bet manager address', async () => {
      const registry = await Registry.deployed();
      betManagerAddress = await registry.getAddress.call('BetManager');
    });

    describe('Test cases for valid spender addition', async () => {

      it('should successfully add a spender', async () => {
        await instance.addSpender(betManagerAddress, {from: owner});
        const isSpender = await instance.isSpender.call(betManagerAddress);
        assert.isTrue(isSpender, 'spender was not added');
      });

    });

    describe('Test cases for invalid spender addition', async () => {

      it('should revert if called by non-owner', async () => {
        try {
          await instance.addSpender(betManagerAddress, {from: accounts[1]}); // non-owner
        } catch (err) {
          ensureException(err);
          return;
        }
        assert.fail('Expected throw not received');
      });

      it('should revert if attempting to add a spender that is not the current BetManager', async () => {
        try {
          await instance.addSpender(NULL_ADDRESS, {from: owner});
        } catch (err) {
          ensureException(err);
          return;
        }
        assert.fail('Expected throw not received');
      });
    });


  });

  describe('Test cases for transferring from', async () => {

    const spenderAddress = accounts[2];
    const fromAccount = accounts[3];
    const toAccount = accounts[4];
    let fromAccountBalanceBefore;
    let toAccountBalanceBefore;

    before('initialize spender', async () => {
      const registry = await Registry.deployed();
      await registry.changeAddress('BetManager', spenderAddress, {from:owner});
      await instance.addSpender(spenderAddress, {from:owner});
      await instance.approve(spenderAddress, {from: fromAccount});
      await instance.deposit(ETH_TOKEN_ADDRESS, 0, {from:fromAccount, value: 2});
      await instance.deposit(ETH_TOKEN_ADDRESS, 0, {from:toAccount, value: 2});

      fromAccountBalanceBefore = await instance.balanceOf(ETH_TOKEN_ADDRESS, fromAccount);
      toAccountBalanceBefore = await instance.balanceOf(ETH_TOKEN_ADDRESS, toAccount);
    });

    describe('Test cases for valid transfer from', async () => {

      it('should successfully transfer token balances', async () => {
        await instance.transferFrom(ETH_TOKEN_ADDRESS, fromAccount, toAccount, 1, {from: spenderAddress});
        const fromAccountBalanceAfter = await instance.balanceOf(ETH_TOKEN_ADDRESS, fromAccount);
        const toAccountBalanceAfter = await instance.balanceOf(ETH_TOKEN_ADDRESS, toAccount);

        assert.equal(fromAccountBalanceAfter.toNumber(), fromAccountBalanceBefore.sub(1).toNumber(), 'tokens did not transfer from account');
        assert.equal(toAccountBalanceAfter.toNumber(), toAccountBalanceBefore.add(1).toNumber(), 'tokens did not transfer to account');
      });

    });

    describe('Test cases for invalid transfer from', async () => {

      it('should revert if `from` address has not approved spender', async () => {
        try {
          await instance.transferFrom(ETH_TOKEN_ADDRESS, toAccount, fromAccount, 1, {from: spenderAddress});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

      it('should revert if amount is not greater than 0', async() => {
        try {
          await instance.transferFrom(ETH_TOKEN_ADDRESS, fromAccount, toAccount, 0, {from: spenderAddress});
        } catch (err) {
          ensureException(err);
          return;
        }

        assert.fail('Expected throw not received');
      });

    });

  });

});
