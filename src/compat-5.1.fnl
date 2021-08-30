; we are porting this to fennel, but it's based on compat 5.1 from
; the kepler project. and sylvanaar's unappreciated vision
; https://github.com/luaforge/compat
; https://authors.curseforge.com/forums/world-of-warcraft/general-chat/lua-code-discussion/224958-using-luas-module-system

;;
;; Compat-5.1
;; Copyright Kepler Project 2004-2006 (http://www.keplerproject.org/compat)
;; According to Lua 5.1
;; $Id: compat-5.1.lua,v 1.22 2006-02-20 21:12:47 carregal Exp $
;;
;; full copyright text at the bottom of the file
;;

(global _COMPAT51 "Compat-5.1 R5")

(local LUA_DIRSEP "/")
(local LUA_OFSEP "_")
(local OLD_LUA_OFSEP "")
(local POF "luaopen_")
(local LUA_PATH_MARK "?")
(local LUA_IGMARK ":")

(local assert assert)
(local error error)
(local getfenv getfenv)
(local ipairs ipairs)
(local loadfile loadfile)
(local loadlib loadlib)
(local pairs pairs)
(local setfenv setfenv)
(local setmetatable setmetatable)
(local type type)

(local find string.find)
(local format string.format)
(local gfind string.gfind)
(local gsub string.gsub)
(local sub string.sub)

;;
;; avoid overwriting the package table if it's already there
;;
(global package (or package {}))
(local _PACKAGE package)

;package.path = LUA_PATH or os.getenv("LUA_PATH") or
;             ("./?.lua;" ..
;              "/usr/local/share/lua/5.0/?.lua;" ..
;              "/usr/local/share/lua/5.0/?/?.lua;" ..
;              "/usr/local/share/lua/5.0/?/init.lua" )
; 
;package.cpath = LUA_CPATH or os.getenv("LUA_CPATH") or
;             "./?.so;" ..
;             "./l?.so;" ..
;             "/usr/local/lib/lua/5.0/?.so;" ..
;             "/usr/local/lib/lua/5.0/l?.so"

;; files/paths are not available in WoW
(set package.path "")
(set package.cpath "")

(set package.config "/\n;\n?\n!\n-\n")

;;
;; make sure require works with standard libraries
;;
(set package.loaded (or package.loaded {}))
(set package.loaded.debug debug)
(set package.loaded.string string)
(set package.loaded.math math)
(set package.loaded.io io)
(set package.loaded.os os)
(set package.loaded.table table )
(set package.loaded.base _G)
(set package.loaded.coroutine coroutine)
(local _LOADED package.loaded)

;;
;; avoid overwriting the package.preload table if it's already there
;;
(set package.preload (or package.preload {}))
(local _PRELOAD package.preload)


;;
;; check whether library is already loaded
;;
(fn loader_preload [name]
  (assert (= (type name) "string")
          (format "bad argument #1 to `require' (string expected, got %s)"
                  (type name)))
  (assert (= (type _PRELOAD) "table") "`package.preload' must be a table")

  (. _PRELOAD name))

(fn loader_WoWAddon [name]
  (if
    (or (= name nil) (= name "")) nil
    (let [(name title ntes enabled loadable reason security) (GetAddOnInfo name)]
      (if (not name) nil
        (do
          (local loaded (IsAddOnLoaded addon))
          (local isondemand (IsAddOnOnDemand addon))
          (if loaded LoadAddOn
            (and loadable isondemand enabled) LoadAddOn
            nil
          ))))))

(fn loader_LibStub [name]
  (if (and _G.LibStub (LibStub:GetLibrary name true)) _G.LibStub))

;; create `loaders' table
(set package.loaders (or package.loaders [loader_preload loader_WoWAddon loader_LibStub]))
(local _LOADERS package.loaders)


;;
;; iterate over available loaders
;;
(fn load [name loaders]
  ;; iterate over available loaders
  (assert (= (type loaders) "table") "`package.loaders' must be a table")
  (var out nil)
  (each [i loader (ipairs loaders) :until out]
    (let [f (loader name)]
      (if f (set out f))
    ))
  (if
    out out
    (error (format "module `%s' not found" name))))

;; sentinel
(fn sentinel [])

;;
;; new require
;;
(global require (fn [modname]
  (assert (= (type modname) "string")
          (format
            "bad argument #1 to `require' (string expected, got %s)"
            (type name)))
  (local p (. _LOADED modname))
  (if ;; is it there?
    p (if
      (= p sentinel) (error (format "loop or previous error loading module '%s'" modname))
      p)
    (do
      (local init (load modname _LOADERS))
      (tset _LOADED modname sentinel)
      (local actual_arg _G.arg)
      (set _G.arg [ modname ])
      (local res (init modname))
      (if res
        (tset _LOADED modname res))
      (global arg actual_arg)
      (if (= (. _LOADED modname) sentinel)
        (tset _LOADED modname true)
      )
      (. _LOADED modname)))))

 ;; findtable
(fn findtable [t f]
  (local ff (.. f "."))
  (fn recurse [found t]
    (local (ok e w) found)
    (if
      (ok) (let [nt (rawget t w)]
             (if
               (not nt) (do (tset t w {}) (recurse (find ff "(.-)%." e+1) (. t w)))
               (not= (type t) "table") (sub f e+1) ;; this seems unreachable?
               (recurse (find ff "(.-)%." e+1) nt)))
      (t)))
  (recurse (find ff "(.-)%." 1) t))

;;
;; new package.seeall function
;;
(fn _PACKAGE.seeall [module]
  (local t  (type module))
  (assert (= t "table") (.. "bad argument #1 to package.seeall (table expected, got " t ")"))
  (local meta (getmetatable module))
  (if (not meta)
    (let [meta {}]
      (setmetatable module meta)
      (tset meta __index _G)
  )
  (tset meta __index _G)
))

;;
;; new module function
;;
(global module (fn [modname ...]
  (local ns (. _LOADED modname))
  (if (not= (type ns) "table") (do
    (local ns (findtable _G modname))
    (if (not ns) (error (string.format "name conflict for module '%s'" modname)))
    (tset _LOADED modname ns)))
  (if (not ns._NAME) ( do
    (set ns._NAME modname)
    (set ns._M ns)
    (set ns._PACKAGE (gsub modname "[^.]*$" ""))
  ))
  (setfenv 2 ns)
  (each [i f (ipairs arg)]
    (f ns)
  )
))

;; Compat-5.1 is free software: it can be used for both academic and commercial purposes at absolutely no cost. There are no royalties or GNU-like "copyleft" restrictions. Compat-5.1 qualifies as Open Source software. Its licenses are compatible with GPL. Compat-5.1 is not in the public domain and the Kepler Project keep its copyright. The legal details are below.
;; 
;; The spirit of the license is that you are free to use Compat-5.1 for any purpose at no cost without having to ask us. The only requirement is that if you do use Compat-5.1, then you should give us credit by including the appropriate copyright notice somewhere in your product or its documentation.
;; 
;; The Compat-5.1 library is designed and implemented by Roberto Ierusalimschy, Diego Nehab, André Carregal and Tomás Guisasola. The implementation is not derived from licensed software.
;; 
;; Copyright © 2004-2006 The Kepler Project.
;; 
;; Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
;; 
;; The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
;; 
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


