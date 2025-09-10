# HUDLimitIncreaser - Copilot Instructions

## Repository Overview

HUDLimitIncreaser is a **highly specialized SourceMod plugin** that increases HUD display limits for money, health, armor, and ammunition in Source engine games (Counter-Strike: Global Offensive and Counter-Strike: Source). This plugin performs **low-level memory patching** of the game server's network data structures.

⚠️ **CRITICAL WARNING**: This plugin directly modifies game engine memory. Incorrect changes can crash game servers or cause data corruption. Exercise extreme caution when making modifications.

## Technical Architecture

### Core Functionality
The plugin works by:
1. **Memory Address Resolution**: Uses gamedata signatures to find memory locations of HUD-related network properties
2. **Bit Field Modification**: Changes the bit allocation for network properties from default values to higher limits:
   - CSGO: Increases to 32 bits
   - CSS: Increases to 17 bits
3. **Network Protocol Manipulation**: Invalidates SendTable CRC to force client-side cache refresh

### Key Components

#### 1. Main Plugin (`addons/sourcemod/scripting/HUDLimitIncreaser.sp`)
- **Engine Detection**: Automatically detects CSGO vs CSS and applies appropriate bit limits
- **Memory Patching**: Directly modifies memory addresses using `StoreToAddress()`
- **Properties Modified**:
  - `m_ArmorValue` - Player armor display
  - `m_iAccount` - Player money display
  - `m_iHealth` - Player health display
  - `m_iClip1` - Weapon clip ammunition
  - `m_iPrimaryReserveAmmoCount` - Primary weapon reserve ammo
  - `m_iSecondaryReserveAmmoCount` - Secondary weapon reserve ammo

#### 2. Gamedata (`addons/sourcemod/gamedata/HUDLimitIncreaser.games.txt`)
- **Memory Signatures**: Platform-specific byte patterns for locating game functions
- **Address Calculations**: Offset-based calculations to find exact memory locations
- **Cross-Platform Support**: Separate addresses and offsets for Windows and Linux

## Development Guidelines

### 🚨 Safety First
1. **Never modify gamedata without thorough testing**
2. **Always test on development servers first**
3. **Backup working gamedata before making changes**
4. **Validate memory addresses before applying patches**
5. **Monitor server stability after deploying changes**

### Code Style & Standards
- Follow SourcePawn conventions from the provided guidelines
- Use descriptive variable names for memory addresses
- Include platform checks for engine-specific code
- Add comments explaining memory patch purposes
- Handle gamedata loading failures gracefully

### Making Changes

#### Modifying Bit Limits
```sourcepawn
// Safe approach for changing bit allocations
int iPatch = 0;
if (GetEngineVersion() == Engine_CSGO)
    iPatch = 32;  // Max safe value for CSGO
else if (GetEngineVersion() == Engine_CSS)
    iPatch = 17;  // Max safe value for CSS

// Always validate address before patching
if (m_ArmorValue != Address_Null)
    StoreToAddress(m_ArmorValue + view_as<Address>(iBits), iPatch, NumberType_Int32);
```

#### Updating Gamedata
**⚠️ EXPERT LEVEL TASK**: Updating signatures and addresses requires:
1. **Reverse Engineering Skills**: Understanding assembly and memory layout
2. **Debugging Tools**: IDA Pro, Ghidra, or similar disassemblers
3. **Pattern Analysis**: Finding stable byte patterns across game updates
4. **Testing Infrastructure**: Multiple game server instances for validation

**When signatures break**:
- Game updates often invalidate memory signatures
- Check the referenced forum thread: https://forums.alliedmods.net/showthread.php?t=309074
- Use the Zombie Plague gamedata as reference: https://github.com/qubka/Zombie-Plague/blob/master/gamedata/plugin.zombieplague.txt

### Build System

This project uses **SourceKnight** as the build system:

```yaml
# sourceknight.yaml configuration
project:
  sourceknight: 0.1
  name: HUDLimitIncreaser
  dependencies:
    - name: sourcemod
      type: tar
      version: 1.11.0-git6917  # Minimum required version
```

#### Building Locally
```bash
# If SourceKnight is installed
sourceknight build

# CI/CD builds automatically on push using GitHub Actions
```

#### CI/CD Pipeline
- **Build**: Uses `maxime1907/action-sourceknight@v1` GitHub Action
- **Package**: Creates distributable archives with plugins and gamedata
- **Release**: Automatic releases on tag pushes and main branch commits

### Testing Strategy

**⚠️ No Unit Testing Available**: Due to the nature of memory patching, traditional unit tests are impossible.

#### Validation Approach
1. **Compilation Testing**: Ensure plugin compiles without errors
2. **Load Testing**: Verify plugin loads on test server without crashes
3. **Functional Testing**: Test HUD displays with values exceeding normal limits
4. **Stability Testing**: Monitor server performance and stability over time

#### Test Environment Setup
```bash
# Required test environment
- SourceMod development server
- Counter-Strike: Global Offensive or Counter-Strike: Source
- Test maps with controllable scenarios
- Methods to artificially increase money/health/ammo beyond normal limits
```

### Common Issues & Troubleshooting

#### Plugin Fails to Load
- **Check SourceMod version**: Requires SourceMod 1.12+ (though dependency shows 1.11.0-git6917)
- **Verify gamedata**: Ensure `HUDLimitIncreaser.games.txt` is in correct location
- **Check signatures**: Game updates may have invalidated memory signatures

#### Memory Access Violations
- **Invalid addresses**: Gamedata signatures may be outdated
- **Incorrect offsets**: Platform-specific offsets may be wrong
- **Engine compatibility**: Ensure engine detection is working properly

#### HUD Limits Not Increased
- **SendTable CRC**: Verify `g_SendTableCRC` is being invalidated properly
- **Client cache**: Clients may need to reconnect to see changes
- **Bit allocation**: Ensure sufficient bits are allocated for desired ranges

### Security Considerations

1. **Memory Safety**: Always validate addresses before writing
2. **Buffer Overflows**: Ensure bit allocations don't exceed safe limits
3. **Game Integrity**: Don't modify values that could affect game balance
4. **Server Stability**: Monitor for crashes or performance degradation

### Debugging Memory Issues

```sourcepawn
// Safe memory patching with validation
if (hConfig == null)
{
    SetFailState("Failed to load gamedata");
    return;
}

Address targetAddr = GameConfGetAddress(hConfig, "m_iHealth");
if (targetAddr == Address_Null)
{
    LogError("Failed to find m_iHealth address");
    return;
}

// Validate before patching
int currentValue = LoadFromAddress(targetAddr + view_as<Address>(iBits), NumberType_Int32);
LogMessage("Current m_iHealth bits: %d, setting to: %d", currentValue, iPatch);
```

### Working with Game Updates

When Valve releases game updates:
1. **Monitor Plugin Functionality**: Check if plugin still loads and functions
2. **Signature Validation**: Verify all gamedata signatures are still valid
3. **Community Resources**: Check SourceMod community for updated signatures
4. **Gradual Deployment**: Test thoroughly before deploying to production servers

### Related Resources

- **SourceMod API Documentation**: https://sm.alliedmods.net/new-api/
- **Gamedata Tutorial**: https://forums.alliedmods.net/showthread.php?t=309074
- **Source Engine Memory Layout**: Various community reverse engineering resources
- **SourcePawn Language Reference**: https://wiki.alliedmods.net/SourcePawn

### Contributing Guidelines

1. **Expertise Required**: Contributors should understand memory management and Source engine internals
2. **Testing Mandatory**: All changes must be tested on actual game servers
3. **Documentation**: Update this file and code comments when making significant changes
4. **Backwards Compatibility**: Maintain support for both CSGO and CSS
5. **Performance Impact**: Monitor server performance impact of any changes

---

**Remember**: This plugin manipulates core game engine functionality. When in doubt, consult experienced SourceMod developers or the community before making changes.