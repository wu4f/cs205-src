# CS 201 Public Autograder Tests

Assignments in this course may be submitted to two batteries of tests.
The first set of tests (this one) is publicly accessible to allow students to
verify that their formatting matches the specification. A second, private suite
of tests may be used to evaluate submissions to prevent "coding to the tests".

# Install pry
The test framework requires pry to be installed.

# Installing and Running the Tests

If you're on PSU's Linux labs, you can simply clone this repository to have access to the current tests:
```
git clone https://bitbucket.org/wuchangfeng/cs201_simd_tests
```

After navigating to the appropriate assignment folder, you can run the tests on your code by pointing them at your submission directory:
```
cd A3
ruby hw3_tests.rb <submission_directory>
```
