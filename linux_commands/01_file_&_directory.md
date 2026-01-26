1. ls
    - ls -l --> long listing
    - ls -a --> show hidden files
    - ls -lh --> human readable sizes
    * ls -lt --> sort by time

2. cp

    cp file1 file1
    cp -r dir1 dir2
    cp -a src dest (preserve permissions)
    cp -v (verbose)

3. mv 
    mv old new
    mv file dir/
    mv -v

4. rm 
    rm file
    rm -r dir/
    rm -f (force)
    rm -rf dir/ (dangerous know it)

5. stat
    stat file
    
6. find
    find . -type f/d
    find . -name "*.log"
    find . -size +10M
    find . -mtime -7
    find . -exec command {} \;