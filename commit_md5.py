import os
import hashlib
import sys

def is_json_file( f ):
    return f[-4:] == 'json'

def is_xlsx_file( f ):
    return f[-4:] == 'xlsx'

def is_lua_file( f ):
    return f[-3:] == 'lua'

class FileMd5:
    def __init__(self, file_path, check_file_func ):
        self.files = []
        files = os.listdir( file_path )
        files.sort()
        for f in files:
            if check_file_func( f ):
                self.files.append( f )

    def make_file_md5(self, except_files = []):
        buf = ''
        for fname in self.files:
            if fname in except_files:
                continue
            print fname
            f = open( fname, 'rb' )
            buf += f.read()
            f.close()
        m = hashlib.md5( buf )
        return m.hexdigest()

def main():
    fm = FileMd5('./', is_lua_file)
    s = fm.make_file_md5(['st_buff.lua','st_skill.lua'])
    f = open( 'md5', 'wb' )
    f.write( s )
    f.close()
    os.system( 'svn commit -m "%s"' % s )

if __name__ == '__main__':
    main()
