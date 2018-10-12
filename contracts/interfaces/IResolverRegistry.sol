pragma solidity ^0.4.24;


/**
 * @title Interface for ResolverRegistry Contract
 * @dev ResolverRegistry keeps track of all the resolvers registered on the FansUnite Platform
 */
contract IResolverRegistry {

  /*
   * @notice Adds resolver `_resolver` to FansUnite's ResolverRegistry, pending registration
   * @dev All resolvers will be manually verified by FansUnite before they are registered
   * @param _resolver Address of the resolver contract
   * @param _class Class of league that resolver `_resolver` will be registered for
   */
  function addResolver(string _class, address _resolver) external;

  /*
   * @notice Registers resolver `_resolver`, only FansUnite can call this
   * @param _resolver Address of the resolver contract
   * @param _class Class of league that resolver `_resolver` will be registered for
   */
  function registerResolver(string _class, address _resolver) external;

  /*
   * @notice Rejects pending resolver `_resolver`, only FansUnite can call this
   * @param _resolver Address of the resolver contract
   * @param _class Class of league that resolver `_resolver` will be rejected for
   */
  function rejectResolver(string _class, address _resolver) external;

  /*
   * @notice Removes registered resolver in `_class` at index `_index`, only FansUnite can call this
   * @param _index Index of the resolver in array resolvers[_class]
   * @param _class Class of league that resolver will be removed for
   */
  function nukeResolver(string _class, uint _index) external;

  /*
   * @notice Add resolver `_resolver` to league `_league`
   * @param _league Address of the league contract
   * @param _resolver Address of the resolver contract
   * @return `true` if league can use resolver `_resolver`, `false` otherwise
   */
  function useResolver(address _league, address _resolver) external;

  /*
   * @notice Gets resolver registered for class `_class`
   * @param _class Class of league
   * @return Addresses of resolvers registered for `_class`
   */
  function getResolvers(string _class) external view returns (address[]);

  /*
   * @notice Returns whether resolver `_resolver` is registered for `_class`
   * @param _class Class of league
   * @param _resolver Address of resolver
   * @return `0` if rejected or not in registry, `1` if pending, `2` if registered
   */
  function isResolverRegistered(string _class, address _resolver) external view returns (uint8);

  /*
   * @notice Checks whether resolver `_resolver` is used in league `_league`
   * @param _league Address of league
   * @param _resolver Address of resolver
   * @return `true` if resolver `_resolver` is used in league `_league`, `false` otherwise
   */
  function isResolverUsed(address _league, address _resolver) external view returns (bool);

}
