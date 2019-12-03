" Automatically run Prettier on save
" autocmd BufWritePre *.['javascript','typescript','css','less','scss','json','graphql','markdown','vue','yaml','html'] Prettier
autocmd BufWritePre *.js Prettier
autocmd BufWritePre *.ts Prettier
autocmd BufWritePre *.css Prettier
autocmd BufWritePre *.scss Prettier
autocmd BufWritePre *.json Prettier
autocmd BufWritePre *.md Prettier
autocmd BufWritePre *.vue Prettier
autocmd BufWritePre *.html Prettier
