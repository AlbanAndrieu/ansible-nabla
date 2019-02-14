Quality & Testing
=================

Commit Hook
-----------

Can be run using ``pre-commit`` tool (http://pre-commit.com/)::

   pre-commit install

   pre-commit run --all-files

   SKIP=ansible-lint git commit -am 'Add key'
   git commit -am 'Add key' --no-verify
