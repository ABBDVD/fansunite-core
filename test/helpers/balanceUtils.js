
class BalanceUtils {

  constructor(vault) {
    this.vault = vault;
  }

  async getBalances(tokenAddress, accounts) {
    let balances = { };
    for ( let key in accounts ) {
      balances[key] = await this.vault.balanceOf.call(tokenAddress, accounts[key]);
    }
    return balances;
  }
}

module.exports = {
  BalanceUtils
};
