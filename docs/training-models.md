# Training Models for Product Management Tasks

> **A complete guide to fine-tuning local LLMs using LM Studio for PM-specific tasks**

## 🎯 Overview

This guide walks Product Managers through the process of fine-tuning local language models using their custom training data. By the end, you'll have a specialized AI assistant that understands your PM workflows and generates content in your style.

## 📋 Prerequisites

Before starting, make sure you have:
- ✅ **LM Studio installed and running** (installed by the main installer)
- ✅ **Training data prepared** (see `docs/creating-training-data.md`)
- ✅ **Base model downloaded** (Phi-3 Mini 4K Instruct recommended)
- ✅ **At least 8GB RAM** (16GB recommended for better performance)
- ✅ **10GB free disk space** for model storage

## 🚀 Quick Start (15 Minutes)

### Step 1: Open LM Studio
1. Launch LM Studio from Applications/Start Menu
2. If not already done, download Phi-3 Mini 4K Instruct from the "Discover" tab
3. Go to the **"Fine-tuning"** tab (looks like a target icon)

### Step 2: Load Your Training Data
1. Click **"Select training file"**
2. Navigate to your `.jsonl` file (e.g., `examples/dataset.jsonl`)
3. LM Studio will validate the format and show preview

### Step 3: Configure Training
1. **Base Model:** Select "Phi-3 Mini 4K Instruct" 
2. **Training Name:** Enter a descriptive name (e.g., "PM-Assistant-v1")
3. **Advanced Settings:** Use defaults for first training

### Step 4: Start Training
1. Click **"Start Fine-tuning"**
2. Training typically takes 10-30 minutes depending on data size
3. Monitor progress in the training log

### Step 5: Test Your Model
1. Once complete, go to the **"Chat"** tab
2. Select your fine-tuned model from the dropdown
3. Test with PM-specific prompts

## ⚙️ Advanced Configuration

### Training Parameters Explained

#### Learning Rate
- **Default:** 2e-4 (recommended for most cases)
- **Lower (1e-4):** More conservative training, less overfitting
- **Higher (5e-4):** Faster learning, risk of overfitting
- **When to adjust:** Use lower rates for small datasets (<50 examples)

#### Batch Size
- **Default:** 4 (good for 8-16GB RAM)
- **Smaller (1-2):** For limited RAM or very long examples
- **Larger (8-16):** For more RAM and faster training
- **Impact:** Larger batches = more stable training

#### Training Epochs
- **Default:** 3 epochs (model sees each example 3 times)
- **More (5-10):** For larger datasets or complex tasks
- **Fewer (1-2):** For small datasets to prevent overfitting
- **Rule of thumb:** More data = fewer epochs needed

#### Context Length
- **Default:** 4096 tokens (matches Phi-3 Mini)
- **Longer examples:** May need truncation or splitting
- **Keep consistent** with base model capabilities

### Advanced Settings for PMs

For PM-specific fine-tuning, try these configurations:

#### Configuration A: High-Quality Documents (PRDs, Specs)
~~~
Learning Rate: 1e-4
Batch Size: 2
Epochs: 5
Context Length: 4096
~~~
*Best for: Detailed, structured documents that need consistency*

#### Configuration B: Quick Communications (Emails, Updates)
~~~
Learning Rate: 3e-4  
Batch Size: 8
Epochs: 3
Context Length: 2048
~~~
*Best for: Shorter, conversational content with variety*

#### Configuration C: Mixed PM Tasks (Balanced)
~~~
Learning Rate: 2e-4
Batch Size: 4
Epochs: 3
Context Length: 4096
~~~
*Best for: General PM assistant with diverse training data*

## 📊 Monitoring Training Progress

### Key Metrics to Watch

#### Training Loss
- **What it means:** How well the model learns the training data
- **Good trend:** Steadily decreasing over time
- **Warning signs:** Loss stops decreasing or increases

#### Validation Loss (if available)
- **What it means:** How well the model generalizes to new data
- **Ideal:** Decreases along with training loss
- **Overfitting:** Training loss decreases but validation increases

#### Training Speed
- **Typical:** 30-100 examples per minute depending on hardware
- **Too slow:** Check if other applications are using GPU/RAM
- **Very fast:** May indicate training issues

### Training Log Interpretation

**Good Training Log:**
~~~
Epoch 1/3 - Loss: 2.45 → 1.82 → 1.54 → 1.31
Epoch 2/3 - Loss: 1.28 → 1.15 → 1.08 → 0.98  
Epoch 3/3 - Loss: 0.95 → 0.89 → 0.84 → 0.79
Training completed successfully!
~~~

**Problem Training Log:**
~~~
Epoch 1/3 - Loss: 2.45 → 2.44 → 2.43 → 2.42 (not learning)
Epoch 2/3 - Loss: 0.15 → 0.02 → 0.001 → 0.0001 (overfitting)
~~~

## 🧪 Testing Your Fine-Tuned Model

### Test Categories for PM Models

#### 1. Format Consistency
**Test Prompt:** "Write a user story for password reset functionality"
**Look for:**
- Proper "As a/I want/So that" structure
- Acceptance criteria included
- Professional tone and language

#### 2. Domain Knowledge
**Test Prompt:** "Explain the difference between OKRs and KPIs"
**Look for:**
- Accurate PM terminology
- Relevant examples
- Clear, actionable explanations

#### 3. Contextual Understanding
**Test Prompt:** "We're 2 weeks behind schedule. Write a stakeholder update."
**Look for:**
- Appropriate tone (urgent but professional)
- Structured communication
- Next steps and mitigation plans

#### 4. Creative Problem-Solving
**Test Prompt:** "Suggest 5 ways to improve user onboarding for a SaaS product"
**Look for:**
- Relevant, actionable suggestions
- PM-specific metrics and success criteria
- Consideration of different user types

### Evaluation Rubric

Rate each test response (1-5 scale):

| Criteria | 1 (Poor) | 3 (Good) | 5 (Excellent) |
|----------|----------|----------|----------------|
| **Accuracy** | Factual errors | Mostly accurate | Completely accurate |
| **Format** | Inconsistent | Follows most patterns | Perfect structure |
| **Relevance** | Generic advice | PM-focused | Highly specific |
| **Completeness** | Missing key elements | Covers most needs | Comprehensive |
| **Tone** | Inappropriate | Professional | Perfect for context |

**Target Score:** Average 4+ across all criteria

## 🔧 Troubleshooting Common Issues

### Training Problems

#### "Out of Memory" Error
**Cause:** Insufficient RAM/GPU memory
**Solutions:**
- Reduce batch size to 1-2
- Use shorter context length (2048 tokens)
- Close other applications
- Restart LM Studio

#### Training Loss Not Decreasing
**Cause:** Learning rate too low or data quality issues
**Solutions:**
- Increase learning rate to 3e-4
- Check training data for errors
- Ensure sufficient data variety (20+ examples minimum)

#### Model Outputs Generic Responses
**Cause:** Overfitting or insufficient training data
**Solutions:**
- Add more diverse examples
- Reduce training epochs
- Increase learning rate slightly

#### Training Fails to Start
**Cause:** Data format issues or corrupted files
**Solutions:**
- Validate JSONL format (each line must be valid JSON)
- Check for special characters or encoding issues
- Try with a smaller subset of data first

### Model Performance Issues

#### Responses Too Short
**Fix:** Add examples with longer, detailed outputs to training data

#### Responses Too Verbose  
**Fix:** Include concise examples and edit training data for brevity

#### Wrong Format/Structure
**Fix:** Ensure training examples consistently use desired format

#### Inappropriate Tone
**Fix:** Review training data tone and add examples with desired voice

## 📈 Model Improvement Strategies

### Iterative Training Process

#### Round 1: Foundation (50-100 examples)
1. Create basic examples across core PM tasks
2. Train initial model
3. Test with common scenarios
4. Identify major gaps

#### Round 2: Specialization (25-50 additional examples)
1. Add examples for identified weak areas
2. Include more complex scenarios
3. Retrain with combined dataset
4. Test edge cases and advanced tasks

#### Round 3: Polish (10-25 additional examples)
1. Fine-tune tone and style
2. Add company-specific terminology
3. Include recent frameworks and tools
4. Final training and validation

### Advanced Techniques

#### Multi-Stage Training
1. **Stage 1:** General PM knowledge (broad dataset)
2. **Stage 2:** Company-specific content (focused dataset)
3. **Stage 3:** Personal style adaptation (your writing samples)

#### Ensemble Approach
- Train multiple specialized models for different PM tasks
- Use task-specific models for better performance
- Example: Separate models for technical specs vs. stakeholder communications

## 📁 Model Management

### Organizing Your Models

#### Naming Convention
- `PM-General-v1` - First general PM assistant
- `PM-PRDs-v2` - Specialized for product requirements
- `PM-Comms-v1` - Focused on stakeholder communication
- `PM-[Company]-v3` - Company-specific customization

#### Version Control
- Keep training data versions aligned with models
- Document what changed between versions
- Maintain notes on performance improvements

#### Storage Management
- Models are typically 2-4GB each
- Archive older versions to save space
- Back up best-performing models

## 🔄 Continuous Improvement

### Monthly Model Updates
1. **Collect new examples** from recent PM work
2. **Review model performance** on current tasks  
3. **Add 10-15 new training examples** addressing gaps
4. **Retrain and compare** with previous version
5. **Deploy best performer** as primary model

### Performance Tracking
- Keep a log of common tasks and model performance
- Track improvement over time
- Note which types of tasks need more training data

### Community Learning
- Share successful training approaches with team
- Collaborate on company-wide PM model
- Contributing to shared training datasets

## 🚀 Production Deployment

### Using Your Fine-Tuned Model

#### In LM Studio
1. **Chat Interface:** Direct conversation with your model
2. **API Mode:** Use in other applications via local API
3. **Model Switching:** Easy switching between specialized models

#### Integration Options
- **VS Code Extensions:** Use with Continue.dev or Cline
- **AnythingLLM:** Upload your model for document chat
- **Custom Applications:** Build PM-specific tools using the local API

### Scaling Across Team
1. **Share successful models** with other PMs
2. **Create team training datasets** combining everyone's examples
3. **Establish model versioning** and update procedures
4. **Set up model performance monitoring** and feedback loops

## 📚 Resources & Next Steps

### Essential Resources
- **Training Data Guide:** `docs/creating-training-data.md`
- **Example Dataset:** `examples/dataset.jsonl` (19 PM examples)
- **LM Studio Documentation:** Built-in help and tutorials
- **Model Cards:** Research papers on Phi-3 and fine-tuning

### Advanced Learning
- **Prompt Engineering:** Techniques for better model interaction
- **Dataset Expansion:** Methods for scaling training data
- **Model Evaluation:** Quantitative assessment techniques
- **Domain Adaptation:** Adapting models for specific industries

### Getting Help
- **LM Studio Community:** Forums and Discord for technical support
- **PM Communities:** Share experiences with other product managers
- **AI/ML Learning:** Courses on fine-tuning and model training

## ✅ Success Checklist

After completing this guide, you should be able to:
- [ ] Load and prepare training data in JSONL format
- [ ] Configure appropriate training parameters for PM tasks
- [ ] Monitor training progress and identify issues
- [ ] Evaluate model performance using PM-specific criteria
- [ ] Troubleshoot common training and performance problems
- [ ] Iteratively improve model quality over time
- [ ] Deploy and use fine-tuned models in your PM workflow

## 🎯 Final Tips

1. **Start simple:** Begin with one task type you do frequently
2. **Quality over quantity:** 20 high-quality examples beat 100 generic ones
3. **Test early and often:** Regular testing prevents wasted training time
4. **Document everything:** Keep notes on what works for future reference
5. **Be patient:** Good models require iteration and refinement

---

**Ready to train your PM assistant?** Start with the example dataset, follow the quick start guide, and gradually build a model that understands your unique PM style and needs.