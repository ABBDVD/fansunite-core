pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "./interfaces/IResolverRegistry.sol";
import "./interfaces/ILeagueRegistry.sol";

import "./utils/RegistryAccessible.sol";


/**
 * @title FansUnite ResolverRegistry Contract
 * @dev ResolverRegistry keeps track of all the resolvers registered on the FansUnite Platform
 */
contract ResolverRegistry is Ownable, IResolverRegistry, RegistryAccessible {

  // class => resolver => registered
  // Resolves to `true` if resolver is registered for class, `false` otherwise
  mapping(string => mapping(address => bool)) registered;
  // Resolves to `true` if resolver is pending registration for class, `false` otherwise
  mapping(string => mapping(address => bool)) pending;
  // Resolves to `true` if resolver is rejected for class, `false` otherwise
  mapping(string => mapping(address => bool)) rejected;
  // Map of classes to addresses of registered resolvers
  mapping(string => address[]) internal resolvers;

  // Emit when new resolver added for pending registration
  event LogResolverPending(string _class, address indexed _resolver);
  // Emit when new resolver successfully registered
  event LogResolverRegistered(string _class, address indexed _resolver);
  // Emit when resolver is rejected
  event LogResolverRejected(string _class, address indexed _resolver);

  /*
   * @title Adds resolver `_resolver` to FansUnite's ResolverRegistry, pending registration
   * @dev All resolvers will be manually verified by FansUnite before they are registered
   * @param _resolver Address of the resolver contract
   * @param _class Class of league that resolver `_resolver` will be registered for
   */
  function addResolver(string _class, address _resolver) external {
    ILeagueRegistry _leagueRegistry = ILeagueRegistry(registry.getAddress("LeagueRegistry"));

    require(!registered[_class][_resolver], "Resolver already registered for class");
    require(!pending[_class][_resolver], "Resolver already pending registration for class");
    require(!rejected[_class][_resolver], "Resolver is rejected for registration");
    require(_leagueRegistry.isClassSupported(_class), "Class is not supported by Fansunite");

    pending[_class][_resolver] = true;

    emit LogResolverPending(_class, _resolver);
  }

  /*
   * @title Registers resolver `_resolver`, only FansUnite can call this
   * @param _resolver Address of the resolver contract
   * @param _class Class of league that resolver `_resolver` will be registered for
   */
  function registerResolver(string _class, address _resolver) external onlyOwner {
    require(!registered[_class][_resolver], "Resolver already registered for class");

    if (rejected[_class][_resolver]) rejected[_class][_resolver] = false;

    pending[_class][_resolver] = false;
    registered[_class][_resolver] = true;
    resolvers[_class].push(_resolver);

    emit LogResolverRegistered(_class, _resolver);
  }

  /*
   * @title Rejects pending resolver `_resolver`, only FansUnite can call this
   * @param _resolver Address of the resolver contract
   * @param _class Class of league that resolver `_resolver` will be rejected for
   */
  function rejectResolver(string _class, address _resolver) external onlyOwner {
    require(!rejected[_class][_resolver], "Resolver already rejected for class");
    require(!registered[_class][_resolver], "Registered resolvers cannot be rejected");

    pending[_class][_resolver] = false;
    rejected[_class][_resolver] = true;

    emit LogResolverRejected(_class, _resolver);
  }

  /*
   * @title Removes registered resolver in `_class` at index `_index`, only FansUnite can call this
   * @param _index Index of the resolver in array resolvers[_class]
   * @param _class Class of league that resolver will be removed for
   */
  function nukeResolver(string _class, uint _index) external onlyOwner {
    // NOTE Resolvers are not nuked from all existing leagues
    address[] storage _resolvers = resolvers[_class];
    require(_index < _resolvers.length, "Index out of bounds.");

    address _resolver = _resolvers[_index];
    require(registered[_class][_resolver], "Resolver not registered");

    registered[_class][_resolver] = false;
    rejected[_class][_resolver] = true;

    delete _resolvers[_index];
    if (_index != _resolvers.length - 1) _resolvers[_index] = _resolvers[_resolvers.length - 1];
    _resolvers.length--;
  }

  /*
   * @title Only registered leagues call this function when they add new resolvers to league
   * @param _class Class of league
   * @param _resolver Address of the resolver contract
   * @return `true` if league can use resolver `_resolver`, `false` otherwise
   */
  function useResolver(string _class, address _resolver) external returns (bool) {
    // Can implement reputation functionality for resolvers here without breaking league001
    // All leagues call useResolver before they register a resolver
    return registered[_class][_resolver];
  }

  /*
   * @title Gets resolver registered for class `_class`
   * @param _class Class of league
   * @return Addresses of resolvers registered for `_class`
   */
  function getResolvers(string _class) external view returns (address[]) {
    return resolvers[_class];
  }

  /*
   * @title Returns whether resolver `_resolver` is registered for `_class`
   * @param _class Class of league
   * @param _resolver Address of resolver
   * @return `0` if rejected or not in registry, `1` if pending, `2` if registered
   */
  function isResolverRegistered(string _class, address _resolver) external view returns (uint8) {
    if (pending[_class][_resolver])
      return 1;
    return registered[_class][_resolver] ? 2 : 0;
  }
}
