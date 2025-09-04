# Creating Training Data for Product Manager Fine-Tuning

> **A complete guide to preparing high-quality training datasets for fine-tuning LLMs for PM tasks**

## 🎯 Overview

This guide shows Product Managers how to create training datasets that will fine-tune local LLMs to better understand PM workflows, terminology, and deliverables.

## 📋 What is Fine-Tuning?

Fine-tuning is the process of taking a pre-trained model (like Phi-3 Mini) and training it further on your specific data to make it better at tasks relevant to your domain. For PMs, this means creating a model that:

- Understands PM terminology and frameworks (OKRs, KPIs, user stories, etc.)
- Follows your company's specific formats and templates
- Generates content that matches your organization's tone and style
- Provides relevant examples and suggestions for PM tasks

## 🗂️ Training Data Format

Training data should be in **JSONL format** (JSON Lines) where each line contains one training example:

~~~json
{"instruction": "What you want the AI to do", "input": "Specific context or request", "output": "The ideal response you want"}
~~~

### Example Structure:
~~~json
{"instruction": "Write a user story", "input": "login functionality for mobile app", "output": "**As a** mobile app user\n**I want to** log into my account securely\n**So that** I can access my personalized content\n\n**Acceptance Criteria:**\n- User can log in with email/password\n- Failed login shows clear error message\n- Remember me option for convenience\n- Password reset link available"}
~~~

## 📝 Types of PM Training Data to Create

### 1. Product Requirements Documents (PRDs)
Train the model to create structured PRDs:

~~~json
{"instruction": "Create a PRD outline", "input": "video calling feature for team collaboration app", "output": "# Video Calling Feature PRD\n\n## Problem Statement\nTeams need face-to-face communication within our collaboration platform\n\n## Success Metrics\n- 60% of teams use video calling weekly\n- Average call duration: 15-30 minutes\n- 4.5+ user satisfaction score\n\n## Core Requirements\n1. One-click video calling from any chat\n2. Screen sharing capability\n3. Recording for async review\n4. Mobile and desktop support\n\n## Non-Goals\n- Large webinars (>50 people)\n- Advanced video editing\n- Third-party integrations (V2)"}
~~~

### 2. User Stories & Acceptance Criteria
Create examples for different feature types:

~~~json
{"instruction": "Write acceptance criteria", "input": "shopping cart functionality", "output": "**Acceptance Criteria for Shopping Cart:**\n\n✅ **Add to Cart**\n- User can add items with one click\n- Quantity selector (1-10 max per item)\n- Cart icon updates with item count\n- Success message confirms addition\n\n✅ **Cart Management**\n- User can view all items in cart\n- Edit quantities or remove items\n- See subtotal, tax, shipping costs\n- Cart persists across browser sessions\n\n✅ **Checkout Flow**\n- Clear call-to-action button\n- Progress indicator during checkout\n- Guest checkout option available"}
~~~

### 3. OKRs and Goal Setting
Examples for strategic planning:

~~~json
{"instruction": "Create quarterly OKRs", "input": "mobile app user engagement", "output": "# Q2 2024 OKRs - Mobile App Engagement\n\n## Objective: Significantly improve mobile app user engagement\n\n### Key Result 1: Increase daily active users by 40%\n- Baseline: 10,000 DAU\n- Target: 14,000 DAU\n- Owner: Growth Team\n\n### Key Result 2: Improve 30-day retention to 65%\n- Baseline: 45% retention\n- Target: 65% retention\n- Owner: Product Team\n\n### Key Result 3: Reduce average session time to value by 50%\n- Baseline: 2 minutes to first value\n- Target: 1 minute to first value\n- Owner: UX Team"}
~~~

### 4. Stakeholder Communications
Train for different communication scenarios:

~~~json
{"instruction": "Write a project delay communication", "input": "feature delayed by 3 weeks due to technical complexity", "output": "Subject: Update on [Feature] Launch Timeline\n\nHi stakeholders,\n\n**TL;DR:** [Feature] launch is moving from March 15 to April 5 (3-week delay)\n\n**Why the delay:**\nOur engineering team discovered additional complexity in the data migration that requires careful handling to prevent user data loss.\n\n**What we're doing:**\n- Added 2 senior engineers to the team\n- Simplified scope for V1 (advanced features moved to V2)\n- Daily progress reviews to prevent further delays\n\n**Updated timeline:**\n- March 22: Complete data migration testing\n- March 29: Feature complete + QA\n- April 5: Launch\n\n**Impact on other projects:** None - this team is dedicated to this feature.\n\nQuestions? Reply or find me on Slack.\n\nThanks for your patience,\n[Your name]"}
~~~

## 🏗️ Step-by-Step Data Creation Process

### Step 1: Gather Real Examples
Start by collecting actual PM documents from your organization:
- Recent PRDs, user stories, and feature specs
- Successful project communications
- OKRs and goal-setting documents
- Meeting notes and stakeholder updates

### Step 2: Identify Patterns
Look for common structures and formats:
- How do you typically structure user stories?
- What sections appear in most PRDs?
- What tone and style does your organization prefer?
- What terminology and frameworks do you use?

### Step 3: Create Training Pairs
For each example, create instruction-input-output triplets:

~~~json
{"instruction": "Write a competitive analysis", "input": "project management tools for remote teams", "output": "[Your ideal competitive analysis format]"}
~~~

### Step 4: Add Variety
Create multiple examples for each task type:
- Different industries and use cases
- Various complexity levels (simple to advanced)
- Different formats (bullet points, tables, paragraphs)
- Various tones (formal, casual, technical)

### Step 5: Quality Check
Each training example should be:
- ✅ **Accurate:** Factually correct and realistic
- ✅ **Consistent:** Follows your organization's style
- ✅ **Complete:** Includes all necessary information
- ✅ **Relevant:** Useful for actual PM tasks

## 📊 Sample Training Data Categories

### Essential PM Tasks (20-30 examples each)
1. **Requirements Gathering**
   - User interviews summaries
   - Feature specifications
   - Technical requirements

2. **Planning & Strategy**
   - Roadmap creation
   - Sprint planning
   - Risk assessment

3. **Communication**
   - Status updates
   - Stakeholder presentations
   - Team coordination

4. **Analytics & Metrics**
   - KPI definitions
   - Data analysis reports
   - A/B test results

### Advanced PM Tasks (10-20 examples each)
5. **Go-to-Market**
   - Launch plans
   - Marketing briefs
   - Sales enablement

6. **Process Improvement**
   - Workflow optimization
   - Tool evaluations
   - Team retrospectives

## 📁 File Organization

Organize your training data by category:

~~~
training-data/
├── user-stories/
│   ├── basic-features.jsonl      # 20 examples
│   ├── complex-workflows.jsonl   # 15 examples
│   └── mobile-specific.jsonl     # 10 examples
├── prds/
│   ├── feature-prds.jsonl        # 25 examples
│   ├── integration-prds.jsonl    # 15 examples
│   └── api-prds.jsonl           # 10 examples
├── communications/
│   ├── status-updates.jsonl      # 20 examples
│   ├── delay-notifications.jsonl # 10 examples
│   └── stakeholder-reports.jsonl # 15 examples
└── analytics/
    ├── kpi-definitions.jsonl     # 15 examples
    ├── metrics-reports.jsonl     # 20 examples
    └── experiment-results.jsonl  # 10 examples
~~~

## ✅ Quality Guidelines

### Good Training Examples:
- **Specific:** Include real-world details and context
- **Actionable:** Provide clear next steps and owners
- **Structured:** Use consistent formatting and sections
- **Professional:** Maintain appropriate tone and language

### Avoid These Mistakes:
- ❌ Generic, templated responses without specifics
- ❌ Inconsistent formatting across examples
- ❌ Outdated terminology or frameworks
- ❌ Examples that don't reflect your actual work

## 🔄 Iterative Improvement

### Start Small, Scale Up:
1. **Week 1:** Create 50 high-quality examples across 3 categories
2. **Week 2:** Train model and test with real PM tasks
3. **Week 3:** Identify gaps and create 25 more targeted examples
4. **Week 4:** Retrain and evaluate improvement

### Continuous Improvement:
- Save good AI outputs as new training examples
- Add examples for tasks where the model struggles  
- Remove or update outdated examples
- Get feedback from other PMs on quality

## 🚀 Next Steps

1. **Review the example dataset** in `examples/dataset.jsonl` for inspiration
2. **Start with one category** that's most important to your work
3. **Create 10-15 high-quality examples** before moving to the next category
4. **Follow the training guide** in `docs/training-models.md` to fine-tune your model
5. **Test and iterate** based on real-world usage

## 💡 Pro Tips

- **Use your own voice:** Include examples written in your personal style
- **Include edge cases:** Cover error scenarios and unusual situations
- **Vary the complexity:** Mix simple and complex examples
- **Stay current:** Include recent frameworks and tools your team uses
- **Get team input:** Have other PMs contribute examples and review quality

## 📚 Resources

- **Example Dataset:** `examples/dataset.jsonl` - 19 PM-focused examples
- **Training Guide:** `docs/training-models.md` - How to fine-tune with your data
- **LM Studio Documentation:** Fine-tuning interface and best practices
- **JSONL Validator:** Tools to check your data format

---

**Ready to create your training data?** Start with the tasks you do most often, and gradually build a comprehensive dataset that reflects your PM expertise and organizational style.