# Directory
1. DebuggingMenu.luau
  - Essentially what the title says, a small debugging menu (before you ask if this is copying deadline, not its not)
2. Destruction.luau
  - Has some edge-cases, but allows for total destruction of parts and is super performant. Uses a quadtree to manage the entire data structure.
3. PlanetGeneration.luau
  - Uses a unitized cube to create a sphere, each face can have an adjustable LOD.
4. Projectile.luau
  - Outdated projectile module, good for people starting off with this stuff.
5. SpaceGame
  - Quite literally a space game that is completely unfinished, also good for people starting off.
6. StressScreenShake.luau
  - Implimentation of GDC Perlin Screen Shake, super duper nice shake.
7. Tagging.luau
  - Interesting way of managing objects in the world.
8. UnfinishedPrototypeWeaponSystem.luau
  - Super good for starters, heavily unfinished viewmodel system for a weapon system. This one copies Tarkov's recoil patterns by using the mouse location as a LookVector, well, a "virual" mouse location. If you read the code you'll understand what I mean.
9 Train.luau
  - Interesting train system, requires 2 modules, Cat-mull Splines and GoodSignal. Does have an edge case that was fixed in the actual production stage of the game; however, I released this unmodified version because it is not subject to copyright.
  - The edge case occurred on sharp parts of the track. To simply fix this, you would need to sample 2 points on the track instead of 1 per cart, then find the unit vector between those 2 points and use that. Whereas this version samples 1 unit vector, which is the tangent of the point on the curve.

# Proud helper to the Fireteam/Swagteam77 development team. Kongo, I hope the game goes well.
<img width="773" alt="image" src="https://github.com/user-attachments/assets/5850eb79-cc1f-45fe-b650-20f7fc51a398" />
