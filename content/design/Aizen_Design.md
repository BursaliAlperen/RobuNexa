# AIZEN DESIGN DOCUMENT

## 🎯 PROJECT GOALS
1. Create AAA quality Aizen moveset with 7 FE skills
2. Implement Fling system with cooldown (koyu gri → açık gri, 1 saniye)
3. Add passive features (UI as LUA CODING ENGINE)
4. Ensure all skills are visible to other players

## 🛠️ CORE SYSTEMS

### 1. FLING SYSTEM
- **Cooldown**: 1 saniye (koyu gri → açık gri)
- **Visual Feedback**: 
  - Tool button turns red when active
  - Particle effect when fling is used
- **Implementation**:
  - Add cooldown variable to tool buttons
  - Create Fling function in source/reanim.lua
  - Add particle effects for fling

### 2. AIZEN SKILLS (7 FE SKILLS)
1. **Aizen Cero** - Basic attack with 1s cooldown
2. **Aizen Shunpo** - Dash ability with 2s cooldown
3. **Aizen Illusion** - Create 3 clones with 5s duration
4. **Aizen Hierro** - Defensive stance with 10s duration
5. **Aizen Cero Oscuro** - Enhanced attack with 15s cooldown
6. **Aizen Kyoka Suigetsu** - Ultimate illusion with 30s cooldown
7. **Aizen Ultimate** - Full screen effect with 60s cooldown

### 3. UI SYSTEM (LUA CODING ENGINE)
- Dark theme (koyu gri)
- Tool buttons with icons
- Cooldown indicators
- Visual feedback for active skills

## 📂 FILE STRUCTURE

```
content/
└── movesets/
    └── Aizen/
        ├── v_aizen.lua
        ├── README.md
        └── assets/
            ├── animations/
            ├── sounds/
            └── effects/
```

## 🧩 IMPLEMENTATION PLAN

### Phase 1: Core Systems
1. Implement Fling function in source/reanim.lua
2. Add cooldown system to UI tools
3. Create particle effects for fling

### Phase 2: Aizen Skills
1. Implement each of the 7 skills
2. Add visual effects for each skill
3. Ensure skills work with other players

### Phase 3: UI Enhancements
1. Create custom icons for each tool
2. Add hover effects to tools
3. Add cooldown visual indicators

## 🎨 VISUAL DESIGN

### Color Scheme
- Primary: Dark gray (koyu gri) - #1a1a1a
- Accent: Electric blue - #00bfff
- Text: White - #ffffff
- Cooldown: Red gradient

### Button Design
- Size: 80x30 pixels
- Rounded corners: 5px radius
- Hover effect: Slightly brighter gray
- Active state: Red tint

## 🚀 DEPLOYMENT PLAN

1. Test Fling system with dummy targets
2. Test all 7 skills with other players
3. Verify UI appears as LUA CODING ENGINE
4. Push to GitHub
5. Add passive features (background music, ambient effects)

## ✅ COMPLETION CHECKLIST

- [ ] Fling system implemented with 1s cooldown
- [ ] All 7 Aizen skills functional
- [ ] UI appears as LUA CODING ENGINE
- [ ] Skills visible to other players
- [ ] Push to GitHub
- [ ] Passive features added

## 📝 NOTES
- Need to add sound effects for each skill
- Need to implement actual skill logic (not just notifications)
- Need to test with multiple players
- Need to add particle effects for visual feedback