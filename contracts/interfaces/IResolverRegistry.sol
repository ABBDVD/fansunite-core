pragma solidity ^0.4.24;


/**
 * @title Interface for ResolverRegistry Contract
 * @dev ResolverRegistry keeps track of all the resolvers registered on the FansUnite Platform
 */
contract IResolverRegistry {

  /*
   * @title Adds resolver `_resolver` to FansUnite's ResolverRegistry, pending registration
   * @dev All resolvers will be manually verified by FansUnite before they are registered
   * @param _resolver Address of the resolver contract
   * @param _class Class of league that resolver `_resolver` will be registered for
   */
  function addResolver(string _class, address _resolver) external;

  /*
   * @title Registers resolver `_resolver`, only FansUnite can call this
   * @param _resolver Address of the resolver contract
   * @param _class Class of league that resolver `_resolver` will be registered for
   */
  function registerResolver(string _class, address _resolver) external;

  /*
   * @title Only registered leagues call this function when they add new resolvers to league
   * @param _class Class of league
   * @param _resolver Address of the resolver contract
   * @return `true` if league can use resolver `_resolver`, `false` otherwise
   */
  function useResolver(string _class, address _resolver) external returns (bool);

  /*
   * @title Gets resolver registered for class `_class`
   * @param _class Class of league
   * @return Addresses of resolvers registered for `_class`
   */
  function getResolvers(string _class) external view returns (address[]);

  /*
   * @title Gets all resolvers pending to be registered
   * @param _class Class of the league
   * @return Addresses of resolvers pending registration for `_class`
   */
  function getPendingResolvers(string _class) external view returns (address[]);

  /*
   * @title Returns whether resolver `_resolver` is registered for `_class`
   * @param _class Class of league
   * @param _resolver Address of resolver
   * @return `0` if not in registry, `1` if pending, `2` if registered
   */
  function isResolverRegistered(string _class, address _resolver) external view returns (uint8);
}
