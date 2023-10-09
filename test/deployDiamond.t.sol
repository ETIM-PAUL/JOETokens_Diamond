// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/facets/JoeTokenFacet.sol";
import "../contracts/Diamond.sol";
import "../contracts/upgradeInitializers/DiamondInit.sol";

import "./helpers/DiamondUtils.sol";

contract DiamondDeployer is DiamondUtils, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    JoeTokenFacet tokenF;
    DiamondInit dInit;

    function testDeployDiamond() public {
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        tokenF = new JoeTokenFacet();
        dInit = new DiamondInit();

        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](3);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );
        cut[2] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("JoeTokenFacet")
            })
        );
        cut[3] = (
            FacetCut({
                facetAddress: address(dInit),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondInit")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();

        //Initialization
        DiamondInit(address(diamond)).init();
    }

    function testDiamondToken() public {
        string memory name = JoeTokenFacet(address(diamond)).name();
        string memory symbol = JoeTokenFacet(address(diamond)).symbol();
        uint256 totalSupply = JoeTokenFacet(address(diamond)).totalSupply();

        assertEq(name, "Diamond Token");
        assertEq(symbol, "DTKN");
        assertEq(totalSupply, 1_000_000e18);
    }

    // multiple initialization should fail
    // function testMultipleInitialize() public {
    //     vm.expectRevert(AlreadyInitialized.selector);
    //     DiamondInit(address(diamond)).init();
    // }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
