find . -type d -name "bin" -prune -exec rm -rf {} \;yes
find . -type d -name "obj" -prune -exec rm -rf {} \;yes
find . -type d -name "TestResults" -prune -exec rm -rf {} \;yes