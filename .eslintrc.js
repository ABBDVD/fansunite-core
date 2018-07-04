module.exports = {
  "extends": "eslint:recommended",
  "rules": {
    "indent": ["error", 2],
    "semi": ["error", "always"],
    "comma-dangle": ["error", "never"]
  },
  "globals" : {
    "artifacts": false,
    "module": false,
    "process": false,
    "contract": false,
    "assert": false,
    "it": false
  }
};
